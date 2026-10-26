package orders_test

import (
	"context"
	"testing"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/inventory"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/orders"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/policies"
	"github.com/google/uuid"
)

func setupTestOrderService(t *testing.T) (*orders.Service, *inventory.Service, *policies.PolicyEngine, uuid.UUID, uuid.UUID, uuid.UUID) {
	ctx := context.Background()
	_ = ctx
	policyEngine := policies.NewPolicyEngine()
	invService := inventory.NewService()

	gameID := uuid.New()
	buyerID := uuid.New()
	sellerID := uuid.New()

	// Seed compliance policy (Article 3)
	policyEngine.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                gameID,
		CountryCode:           "US",
		ProductType:           domain.ProductTypeGameItem,
		TradeEnabled:          true,
		LegalReviewStatus:     "APPROVED",
		PublisherPolicyStatus: "PERMITTED",
		PaymentPartnerStatus:  "APPROVED",
	})

	// Seed listing in inventory
	listing := &domain.Listing{
		ID:                uuid.New(),
		SellerID:          sellerID,
		GameID:            gameID,
		Title:             "Exalted Orb Stack",
		ProductType:       domain.ProductTypeGameItem,
		CurrencyCode:      "USD",
		UnitPriceMinor:    100, // $1.00
		AvailableQuantity: 50,
		MinimumQuantity:   1,
		MaximumQuantity:   100,
		Status:            "ACTIVE",
	}
	invService.SeedListing(listing)

	ordService := orders.NewService(policyEngine, invService)
	return ordService, invService, policyEngine, buyerID, sellerID, listing.ID
}

func TestOrderService_FullLifecycleTransitions(t *testing.T) {
	ctx := context.Background()
	ordSvc, _, _, buyerID, _, listingID := setupTestOrderService(t)

	// Step 1: Create Quote
	quote, err := ordSvc.CreateQuote(ctx, buyerID, listingID, 10, "US")
	if err != nil {
		t.Fatalf("CreateQuote failed: %v", err)
	}
	if quote.TotalMinor != 1000 {
		t.Fatalf("expected total 1000 minor ($10.00), got %d", quote.TotalMinor)
	}

	// Step 2: Place Order (Reserves inventory)
	order, reservation, err := ordSvc.PlaceOrder(ctx, quote, "Trade at Lioneye's Watch")
	if err != nil {
		t.Fatalf("PlaceOrder failed: %v", err)
	}
	if order.OrderStatus != domain.OrderStatusAwaitingPayment {
		t.Fatalf("expected order status AWAITING_PAYMENT, got %s", order.OrderStatus)
	}
	if reservation.Quantity != 10 {
		t.Fatalf("expected reserved qty 10, got %d", reservation.Quantity)
	}

	// Step 3: Transition AWAITING_PAYMENT -> PAYMENT_PENDING
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusPaymentPending, "SYSTEM", nil, "PSP checkout opened")
	if err != nil {
		t.Fatalf("transition to PAYMENT_PENDING failed: %v", err)
	}

	// Step 4: Transition PAYMENT_PENDING -> PAYMENT_CONFIRMED (Webhook received)
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusPaymentConfirmed, "PSP_WEBHOOK", nil, "Payment authorized in escrow")
	if err != nil {
		t.Fatalf("transition to PAYMENT_CONFIRMED failed: %v", err)
	}

	// Step 5: Transition PAYMENT_CONFIRMED -> FULFILLMENT_PENDING
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusFulfillmentPending, "SYSTEM", nil, "Seller notified to fulfill")
	if err != nil {
		t.Fatalf("transition to FULFILLMENT_PENDING failed: %v", err)
	}

	// Step 6: Transition FULFILLMENT_PENDING -> DELIVERY_CLAIMED (Evidence uploaded)
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusDeliveryClaimed, "SELLER", nil, "Delivery proof uploaded with SHA256")
	if err != nil {
		t.Fatalf("transition to DELIVERY_CLAIMED failed: %v", err)
	}

	// Step 7: Transition DELIVERY_CLAIMED -> BUYER_REVIEW
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusBuyerReview, "SYSTEM", nil, "24h inspection window started")
	if err != nil {
		t.Fatalf("transition to BUYER_REVIEW failed: %v", err)
	}

	// Step 8: Transition BUYER_REVIEW -> COMPLETED (Buyer confirms or auto-release)
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusCompleted, "BUYER", &buyerID, "Buyer confirmed asset receipt in-game")
	if err != nil {
		t.Fatalf("transition to COMPLETED failed: %v", err)
	}

	finalOrder, err := ordSvc.GetOrder(order.ID)
	if err != nil {
		t.Fatalf("GetOrder failed: %v", err)
	}
	if finalOrder.OrderStatus != domain.OrderStatusCompleted {
		t.Fatalf("expected final order status COMPLETED, got %s", finalOrder.OrderStatus)
	}
}

func TestOrderService_ProhibitedInvalidTransition(t *testing.T) {
	ctx := context.Background()
	ordSvc, _, _, buyerID, _, listingID := setupTestOrderService(t)

	quote, err := ordSvc.CreateQuote(ctx, buyerID, listingID, 5, "US")
	if err != nil {
		t.Fatalf("CreateQuote failed: %v", err)
	}

	order, _, err := ordSvc.PlaceOrder(ctx, quote, "Note")
	if err != nil {
		t.Fatalf("PlaceOrder failed: %v", err)
	}

	// Attempt illegal skip: AWAITING_PAYMENT directly to COMPLETED
	err = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusCompleted, "BUYER", &buyerID, "Illegal jump")
	if err == nil {
		t.Fatalf("expected error on illegal state transition, got nil")
	}
}

func TestOrderService_Article34ProhibitedAccountGating(t *testing.T) {
	ctx := context.Background()
	ordSvc, invSvc, _, buyerID, sellerID, _ := setupTestOrderService(t)

	// Create listing with prohibited GAME_ACCOUNT product type
	gameID := uuid.New()
	accountListing := &domain.Listing{
		ID:                uuid.New(),
		SellerID:          sellerID,
		GameID:            gameID,
		Title:             "Max Level PoE Account with Full Gear",
		ProductType:       domain.ProductTypeGameAccount, // BANNED
		CurrencyCode:      "USD",
		UnitPriceMinor:    10000,
		AvailableQuantity: 1,
		MinimumQuantity:   1,
		MaximumQuantity:   1,
		Status:            "ACTIVE",
	}
	invSvc.SeedListing(accountListing)

	// Quote creation MUST be blocked unconditionally by Article 3.4
	_, err := ordSvc.CreateQuote(ctx, buyerID, accountListing.ID, 1, "US")
	if err == nil {
		t.Fatalf("expected error blocking GAME_ACCOUNT trade, got nil")
	}
}

