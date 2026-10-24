package orders

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/inventory"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/policies"
	"github.com/google/uuid"
)

// AllowedTransitions maps valid from -> to order states per Article 15.2
var AllowedTransitions = map[string][]string{
	domain.OrderStatusCreated: {
		domain.OrderStatusPolicyChecked,
		domain.OrderStatusCancelled,
	},
	domain.OrderStatusPolicyChecked: {
		domain.OrderStatusAwaitingPayment,
		domain.OrderStatusCancelled,
	},
	domain.OrderStatusAwaitingPayment: {
		domain.OrderStatusPaymentPending,
		domain.OrderStatusCancelled,
		domain.OrderStatusExpired,
	},
	domain.OrderStatusPaymentPending: {
		domain.OrderStatusPaymentConfirmed,
		domain.OrderStatusAwaitingPayment,
		domain.OrderStatusCancelled,
	},
	domain.OrderStatusPaymentConfirmed: {
		domain.OrderStatusFulfillmentPending,
	},
	domain.OrderStatusFulfillmentPending: {
		domain.OrderStatusDeliveryClaimed,
		domain.OrderStatusDisputed,
		domain.OrderStatusCancelled,
	},
	domain.OrderStatusDeliveryClaimed: {
		domain.OrderStatusBuyerReview,
		domain.OrderStatusDisputed,
	},
	domain.OrderStatusBuyerReview: {
		domain.OrderStatusCompleted,
		domain.OrderStatusDisputed,
	},
	domain.OrderStatusDisputed: {
		domain.OrderStatusCompleted,
		domain.OrderStatusRefundPending,
	},
	domain.OrderStatusRefundPending: {
		domain.OrderStatusRefunded,
	},
}

type Service struct {
	mu           sync.RWMutex
	policyEngine *policies.PolicyEngine
	invService   *inventory.Service
	orders       map[uuid.UUID]*domain.Order
	history      []domain.OrderStatusHistory
	orderNumber  int64
}

func NewService(policyEngine *policies.PolicyEngine, invService *inventory.Service) *Service {
	return &Service{
		policyEngine: policyEngine,
		invService:   invService,
		orders:       make(map[uuid.UUID]*domain.Order),
		history:      make([]domain.OrderStatusHistory, 0),
		orderNumber:  1000,
	}
}

// CreateQuote calculates pricing breakdown per Article 12 & 16.5
func (s *Service) CreateQuote(ctx context.Context, buyerID, listingID uuid.UUID, quantity int, buyerCountry string) (*domain.OrderQuote, error) {
	listing, err := s.invService.GetListing(listingID)
	if err != nil {
		return nil, err
	}

	// Compliance Gate
	if err := s.policyEngine.ValidateTrade(ctx, listing.GameID, buyerCountry, listing.ProductType); err != nil {
		return nil, err
	}

	if quantity < listing.MinimumQuantity || quantity > listing.MaximumQuantity {
		return nil, fmt.Errorf("quantity %d outside listing bounds [%d, %d]", quantity, listing.MinimumQuantity, listing.MaximumQuantity)
	}

	subtotal := listing.UnitPriceMinor * int64(quantity)
	// Default 5% seller fee, 0% buyer fee
	buyerFee := int64(0)
	tax := int64(0)
	total := subtotal + buyerFee + tax

	quote := &domain.OrderQuote{
		ID:               uuid.New(),
		BuyerUserID:      buyerID,
		ListingID:        listingID,
		Quantity:         quantity,
		UnitPriceMinor:   listing.UnitPriceMinor,
		SubtotalMinor:    subtotal,
		PlatformFeeMinor: buyerFee,
		PaymentFeeMinor:  0,
		TaxMinor:         tax,
		TotalMinor:       total,
		CurrencyCode:     listing.CurrencyCode,
		FeePolicyVersion: "v1.0",
		ExpiresAt:        time.Now().Add(15 * time.Minute),
		CreatedAt:        time.Now(),
	}

	return quote, nil
}

// PlaceOrder initializes an order and atomically reserves inventory
func (s *Service) PlaceOrder(ctx context.Context, quote *domain.OrderQuote, deliveryNote string) (*domain.Order, *domain.InventoryReservation, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if quote == nil {
		return nil, nil, fmt.Errorf("order quote cannot be nil")
	}

	if time.Now().After(quote.ExpiresAt) {
		return nil, nil, fmt.Errorf("order quote has expired")
	}

	listing, err := s.invService.GetListing(quote.ListingID)
	if err != nil {
		return nil, nil, err
	}

	orderID := uuid.New()
	s.orderNumber++
	orderNumStr := fmt.Sprintf("ORD-%d-%s", s.orderNumber, orderID.String()[:6])

	// Reserve inventory atomically (Article 11.5)
	reservation, err := s.invService.ReserveStock(ctx, quote.ListingID, orderID, quote.Quantity, 30*time.Minute)
	if err != nil {
		return nil, nil, fmt.Errorf("failed to reserve stock: %w", err)
	}

	sellerFee := int64(float64(quote.SubtotalMinor) * 0.05) // 5% seller fee

	order := &domain.Order{
		ID:                orderID,
		OrderNumber:       orderNumStr,
		BuyerUserID:       quote.BuyerUserID,
		SellerID:          listing.SellerID,
		ListingID:         listing.ID,
		QuoteID:           quote.ID,
		Quantity:          quote.Quantity,
		CurrencyCode:      quote.CurrencyCode,
		SubtotalMinor:     quote.SubtotalMinor,
		BuyerFeeMinor:     quote.PlatformFeeMinor,
		SellerFeeMinor:    sellerFee,
		TaxMinor:          quote.TaxMinor,
		TotalMinor:        quote.TotalMinor,
		OrderStatus:       domain.OrderStatusAwaitingPayment,
		PaymentStatus:     domain.PaymentStatusNotStarted,
		FulfillmentStatus: "UNFULFILLED",
		PayoutStatus:      domain.PayoutStatusNotEligible,
		DeliveryNote:      deliveryNote,
		Version:           1,
		PlacedAt:          time.Now(),
		CreatedAt:         time.Now(),
		UpdatedAt:         time.Now(),
	}

	s.orders[orderID] = order

	hist := domain.OrderStatusHistory{
		ID:         uuid.New(),
		OrderID:    orderID,
		FromStatus: domain.OrderStatusCreated,
		ToStatus:   domain.OrderStatusAwaitingPayment,
		ActorType:  "BUYER",
		ActorID:    &quote.BuyerUserID,
		Reason:     "Order created from quote with reserved inventory",
		CreatedAt:  time.Now(),
	}
	s.history = append(s.history, hist)

	return order, reservation, nil
}

// TransitionOrder validates and applies status change adhering to state machine
func (s *Service) TransitionOrder(ctx context.Context, orderID uuid.UUID, toStatus, actorType string, actorID *uuid.UUID, reason string) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	order, exists := s.orders[orderID]
	if !exists {
		return domain.ErrNotFound
	}

	fromStatus := order.OrderStatus
	allowed := false
	for _, next := range AllowedTransitions[fromStatus] {
		if next == toStatus {
			allowed = true
			break
		}
	}

	if !allowed {
		return fmt.Errorf("%w: cannot transition from %s to %s", domain.ErrInvalidStateTransition, fromStatus, toStatus)
	}

	order.OrderStatus = toStatus
	order.UpdatedAt = time.Now()
	order.Version++

	hist := domain.OrderStatusHistory{
		ID:         uuid.New(),
		OrderID:    orderID,
		FromStatus: fromStatus,
		ToStatus:   toStatus,
		ActorType:  actorType,
		ActorID:    actorID,
		Reason:     reason,
		CreatedAt:  time.Now(),
	}
	s.history = append(s.history, hist)

	return nil
}

func (s *Service) GetOrder(id uuid.UUID) (*domain.Order, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	o, exists := s.orders[id]
	if !exists {
		return nil, domain.ErrNotFound
	}
	res := *o
	return &res, nil
}
