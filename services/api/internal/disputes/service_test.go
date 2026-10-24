package disputes_test

import (
	"context"
	"testing"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/disputes"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/inventory"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/orders"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/policies"
	"github.com/google/uuid"
)

func TestDisputes_DualApprovalForRefundDecisions(t *testing.T) {
	pe := policies.NewPolicyEngine()
	inv := inventory.NewService()
	ordSvc := orders.NewService(pe, inv)
	dispSvc := disputes.NewService(ordSvc)

	ctx := context.Background()

	buyerID := uuid.New()
	sellerID := uuid.New()
	listingID := uuid.New()
	gameID := uuid.New()

	pe.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                gameID,
		CountryCode:           "US",
		ProductType:           domain.ProductTypeGameItem,
		LegalReviewStatus:     "APPROVED",
		PublisherPolicyStatus: "PERMITTED",
		PaymentPartnerStatus:  "APPROVED",
		TradeEnabled:          true,
	})

	listing := &domain.Listing{
		ID:                listingID,
		GameID:            gameID,
		SellerID:          sellerID,
		ProductType:       domain.ProductTypeGameItem,
		UnitPriceMinor:    5000,
		CurrencyCode:      "USD",
		AvailableQuantity: 10,
		MinimumQuantity:   1,
		MaximumQuantity:   10,
	}
	inv.SeedListing(listing)

	quote, err := ordSvc.CreateQuote(ctx, buyerID, listingID, 1, "US")
	if err != nil {
		t.Fatalf("failed creating quote: %v", err)
	}
	order, _, err := ordSvc.PlaceOrder(ctx, quote, "Delivery note")
	if err != nil {
		t.Fatalf("failed placing order: %v", err)
	}

	// Transition to Payment Confirmed -> Fulfillment Pending
	_ = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusPaymentPending, "SYSTEM", nil, "payment pending")
	_ = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusPaymentConfirmed, "PSP", nil, "payment confirmed")
	_ = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusFulfillmentPending, "SYSTEM", nil, "fulfillment pending")

	// 1. Open Dispute
	dispute, err := dispSvc.OpenDispute(ctx, order.ID, buyerID, "NOT_AS_DESCRIBED", "Delivered item stat does not match listing description")
	if err != nil {
		t.Fatalf("unexpected error opening dispute: %v", err)
	}

	o, _ := ordSvc.GetOrder(order.ID)
	if o.OrderStatus != domain.OrderStatusDisputed {
		t.Fatalf("expected order status DISPUTED, got: %s", o.OrderStatus)
	}

	// 2. First Admin (Decider) proposes full refund
	deciderAdminID := uuid.New()
	decision, err := dispSvc.DecideDispute(ctx, dispute.ID, "BUYER_FAVOR_FULL_REFUND", "Evidence confirms item discrepancy", deciderAdminID)
	if err != nil {
		t.Fatalf("unexpected error recording decision: %v", err)
	}

	// Per Article 29: Must be PENDING_APPROVAL until 4-eyes secondary check
	if decision.ApprovalStatus != "PENDING_APPROVAL" {
		t.Fatalf("expected PENDING_APPROVAL for refund decision, got: %s", decision.ApprovalStatus)
	}

	// 3. Same Admin attempting to approve their own decision must be REJECTED (Segregation of Duties)
	if err := dispSvc.ApproveDisputeDecision(ctx, decision.ID, deciderAdminID); err == nil {
		t.Fatalf("expected segregation of duties violation, but self-approval was accepted")
	}

	// 4. Secondary Admin (Finance Approver) approves
	secondaryAdminID := uuid.New()
	if err := dispSvc.ApproveDisputeDecision(ctx, decision.ID, secondaryAdminID); err != nil {
		t.Fatalf("unexpected error approving decision by second admin: %v", err)
	}

	o, _ = ordSvc.GetOrder(order.ID)
	if o.OrderStatus != domain.OrderStatusRefundPending {
		t.Fatalf("expected order to move to REFUND_PENDING after dual-approval, got: %s", o.OrderStatus)
	}
}
