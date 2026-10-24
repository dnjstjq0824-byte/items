package delivery

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/orders"
	"github.com/google/uuid"
)

type EvidenceInput struct {
	MediaAssetID uuid.UUID `json:"media_asset_id"`
	EvidenceType string    `json:"evidence_type"`
	Description  string    `json:"description"`
	Checksum     string    `json:"checksum"`
}

type Service struct {
	mu           sync.Mutex
	orderService *orders.Service
	deliveries   map[uuid.UUID]*domain.Delivery
	evidences    map[uuid.UUID][]domain.DeliveryEvidence
}

func NewService(orderService *orders.Service) *Service {
	return &Service{
		orderService: orderService,
		deliveries:   make(map[uuid.UUID]*domain.Delivery),
		evidences:    make(map[uuid.UUID][]domain.DeliveryEvidence),
	}
}

// ClaimDelivery records seller's fulfillment with required evidence (Article 17.2 & 17.3)
func (s *Service) ClaimDelivery(ctx context.Context, orderID, sellerID uuid.UUID, method string, evidenceList []EvidenceInput) (*domain.Delivery, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	order, err := s.orderService.GetOrder(orderID)
	if err != nil {
		return nil, err
	}

	if order.SellerID != sellerID {
		return nil, domain.ErrForbidden
	}

	if order.OrderStatus != domain.OrderStatusPaymentConfirmed && order.OrderStatus != domain.OrderStatusFulfillmentPending {
		return nil, fmt.Errorf("cannot claim delivery in status %s (payment must be confirmed)", order.OrderStatus)
	}

	if len(evidenceList) == 0 {
		return nil, fmt.Errorf("verified delivery evidence is mandatory (Article 17.2)")
	}

	now := time.Now()
	deliveryID := uuid.New()
	delivery := &domain.Delivery{
		ID:               deliveryID,
		OrderID:          orderID,
		DeliveryMethod:   method,
		SellerClaimedAt:  &now,
		Status:           "DELIVERY_CLAIMED",
		CreatedAt:        now,
		UpdatedAt:        now,
	}

	for _, ev := range evidenceList {
		if len(ev.Checksum) < 32 {
			return nil, fmt.Errorf("invalid checksum for evidence media %s", ev.MediaAssetID)
		}
		evidenceRecord := domain.DeliveryEvidence{
			ID:                uuid.New(),
			DeliveryID:        deliveryID,
			SubmittedByUserID: sellerID,
			MediaAssetID:      ev.MediaAssetID,
			EvidenceType:      ev.EvidenceType,
			Description:       ev.Description,
			Checksum:          ev.Checksum,
			CreatedAt:         now,
		}
		s.evidences[deliveryID] = append(s.evidences[deliveryID], evidenceRecord)
	}

	s.deliveries[orderID] = delivery

	// Advance Order State Machine
	if order.OrderStatus == domain.OrderStatusPaymentConfirmed {
		if err := s.orderService.TransitionOrder(ctx, orderID, domain.OrderStatusFulfillmentPending, "SELLER", &sellerID, "Fulfillment started"); err != nil {
			return nil, err
		}
	}

	if err := s.orderService.TransitionOrder(ctx, orderID, domain.OrderStatusDeliveryClaimed, "SELLER", &sellerID, "Delivery claimed with evidence submitted"); err != nil {
		return nil, err
	}

	return delivery, nil
}

// BuyerConfirm marks order complete upon satisfactory delivery confirmation (Article 17.4)
func (s *Service) BuyerConfirm(ctx context.Context, orderID, buyerID uuid.UUID) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	order, err := s.orderService.GetOrder(orderID)
	if err != nil {
		return err
	}

	if order.BuyerUserID != buyerID {
		return domain.ErrForbidden
	}

	delivery, exists := s.deliveries[orderID]
	if !exists || delivery.Status != "DELIVERY_CLAIMED" {
		return fmt.Errorf("no pending delivery to confirm for order %s", orderID)
	}

	now := time.Now()
	delivery.BuyerConfirmedAt = &now
	delivery.Status = "CONFIRMED"
	delivery.UpdatedAt = now

	// Advance order state: DELIVERY_CLAIMED -> BUYER_REVIEW -> COMPLETED
	if err := s.orderService.TransitionOrder(ctx, orderID, domain.OrderStatusBuyerReview, "BUYER", &buyerID, "Buyer review started"); err != nil {
		return err
	}

	if err := s.orderService.TransitionOrder(ctx, orderID, domain.OrderStatusCompleted, "BUYER", &buyerID, "Buyer confirmed receipt"); err != nil {
		return err
	}

	return nil
}

func (s *Service) GetDelivery(orderID uuid.UUID) (*domain.Delivery, []domain.DeliveryEvidence, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	d, exists := s.deliveries[orderID]
	if !exists {
		return nil, nil, domain.ErrNotFound
	}
	evs := s.evidences[d.ID]
	return d, evs, nil
}

