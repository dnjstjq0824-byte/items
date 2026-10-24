package inventory

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/google/uuid"
)

// Service manages atomic inventory reservations and invariant enforcement
type Service struct {
	mu           sync.Mutex
	listings     map[uuid.UUID]*domain.Listing
	reservations map[uuid.UUID]*domain.InventoryReservation
}

func NewService() *Service {
	return &Service{
		listings:     make(map[uuid.UUID]*domain.Listing),
		reservations: make(map[uuid.UUID]*domain.InventoryReservation),
	}
}

func (s *Service) SeedListing(l *domain.Listing) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.listings[l.ID] = l
}

func (s *Service) GetListing(id uuid.UUID) (*domain.Listing, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	l, exists := s.listings[id]
	if !exists {
		return nil, domain.ErrNotFound
	}
	// Return a copy
	res := *l
	return &res, nil
}

// ReserveStock atomically holds available inventory for checkout duration
func (s *Service) ReserveStock(ctx context.Context, listingID, orderID uuid.UUID, quantity int, ttl time.Duration) (*domain.InventoryReservation, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	listing, exists := s.listings[listingID]
	if !exists {
		return nil, domain.ErrNotFound
	}

	if quantity <= 0 {
		return nil, fmt.Errorf("invalid quantity: %d", quantity)
	}

	if listing.AvailableQuantity < quantity {
		return nil, fmt.Errorf("%w: requested %d, available %d", domain.ErrInsufficientInventory, quantity, listing.AvailableQuantity)
	}

	// Atomic update maintaining Article 23 invariant
	listing.AvailableQuantity -= quantity
	listing.ReservedQuantity += quantity
	listing.UpdatedAt = time.Now()

	resID := uuid.New()
	reservation := &domain.InventoryReservation{
		ID:        resID,
		ListingID: listingID,
		OrderID:   orderID,
		Quantity:  quantity,
		Status:    "ACTIVE",
		ExpiresAt: time.Now().Add(ttl),
		CreatedAt: time.Now(),
	}

	s.reservations[resID] = reservation
	return reservation, nil
}

// ReleaseReservation rolls back reserved stock back to available (e.g. timeout or payment cancel)
func (s *Service) ReleaseReservation(ctx context.Context, reservationID uuid.UUID, reason string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	res, exists := s.reservations[reservationID]
	if !exists {
		return domain.ErrNotFound
	}

	if res.Status != "ACTIVE" {
		return fmt.Errorf("reservation %s is not active (current: %s)", reservationID, res.Status)
	}

	listing, exists := s.listings[res.ListingID]
	if !exists {
		return domain.ErrNotFound
	}

	// Invariant check: cannot decrement reserved below zero
	if listing.ReservedQuantity < res.Quantity {
		return fmt.Errorf("invariant violation: reserved stock %d < reservation quantity %d", listing.ReservedQuantity, res.Quantity)
	}

	listing.ReservedQuantity -= res.Quantity
	listing.AvailableQuantity += res.Quantity
	listing.UpdatedAt = time.Now()

	if reason == "EXPIRED" {
		res.Status = "EXPIRED"
	} else {
		res.Status = "RELEASED"
	}

	return nil
}

// ConsumeReservation commits reserved stock to sold upon confirmed payment capture
func (s *Service) ConsumeReservation(ctx context.Context, reservationID uuid.UUID) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	res, exists := s.reservations[reservationID]
	if !exists {
		return domain.ErrNotFound
	}

	if res.Status != "ACTIVE" {
		return fmt.Errorf("reservation %s is not active (current: %s)", reservationID, res.Status)
	}

	listing, exists := s.listings[res.ListingID]
	if !exists {
		return domain.ErrNotFound
	}

	if listing.ReservedQuantity < res.Quantity {
		return fmt.Errorf("invariant violation: reserved stock %d < reservation quantity %d", listing.ReservedQuantity, res.Quantity)
	}

	listing.ReservedQuantity -= res.Quantity
	listing.SoldQuantity += res.Quantity
	listing.UpdatedAt = time.Now()

	res.Status = "CONSUMED"
	return nil
}

// ExpireStaleReservations checks and releases any reservations past TTL
func (s *Service) ExpireStaleReservations(ctx context.Context) int {
	s.mu.Lock()
	defer s.mu.Unlock()

	now := time.Now()
	expiredCount := 0

	for _, res := range s.reservations {
		if res.Status == "ACTIVE" && now.After(res.ExpiresAt) {
			if listing, ok := s.listings[res.ListingID]; ok {
				listing.ReservedQuantity -= res.Quantity
				listing.AvailableQuantity += res.Quantity
				listing.UpdatedAt = now
			}
			res.Status = "EXPIRED"
			expiredCount++
		}
	}

	return expiredCount
}

