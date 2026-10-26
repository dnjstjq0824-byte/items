package delivery_test

import (
	"context"
	"testing"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/delivery"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/inventory"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/orders"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/policies"
	"github.com/google/uuid"
)

func setupTestDeliveryEnvironment(t *testing.T) (*delivery.Service, *orders.Service, uuid.UUID, uuid.UUID, uuid.UUID) {
	ctx := context.Background()
	_ = ctx
	pe := policies.NewPolicyEngine()
	inv := inventory.NewService()
	ordSvc := orders.NewService(pe, inv)
	delSvc := delivery.NewService(ordSvc)

	buyerID := uuid.New()
	sellerID := uuid.New()
	gameID := uuid.New()
	listingID := uuid.New()

	pe.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                gameID,
		CountryCode:           "US",
		ProductType:           domain.ProductTypeGameItem,
		TradeEnabled:          true,
		LegalReviewStatus:     "APPROVED",
		PublisherPolicyStatus: "PERMITTED",
		PaymentPartnerStatus:  "APPROVED",
	})

	listing := &domain.Listing{
		ID:                listingID,
		SellerID:          sellerID,
		GameID:            gameID,
		Title:             "Rare Wand",
		ProductType:       domain.ProductTypeGameItem,
		CurrencyCode:      "USD",
		UnitPriceMinor:    2500,
		AvailableQuantity: 10,
		MinimumQuantity:   1,
		MaximumQuantity:   10,
		Status:            "ACTIVE",
	}
	inv.SeedListing(listing)

	return delSvc, ordSvc, buyerID, sellerID, listingID
}

func TestDelivery_ClaimDeliveryWithEvidenceAndBuyerConfirm(t *testing.T) {
	ctx := context.Background()
	delSvc, ordSvc, buyerID, sellerID, listingID := setupTestDeliveryEnvironment(t)

	// 1. Create quote & place order
	quote, err := ordSvc.CreateQuote(ctx, buyerID, listingID, 1, "US")
	if err != nil {
		t.Fatalf("CreateQuote failed: %v", err)
	}
	order, _, err := ordSvc.PlaceOrder(ctx, quote, "Handover in town")
	if err != nil {
		t.Fatalf("PlaceOrder failed: %v", err)
	}

	// 2. Transition to PAYMENT_CONFIRMED
	_ = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusPaymentPending, "SYSTEM", nil, "paid")
	_ = ordSvc.TransitionOrder(ctx, order.ID, domain.OrderStatusPaymentConfirmed, "PSP", nil, "funds captured")

	// 3. Test: Claim delivery without evidence must fail (Article 17.2)
	_, err = delSvc.ClaimDelivery(ctx, order.ID, sellerID, "DIRECT_TRADE", []delivery.EvidenceInput{})
	if err == nil {
		t.Fatalf("expected error claiming delivery without evidence, got nil")
	}

	// 4. Test: Claim delivery with short/invalid checksum must fail
	_, err = delSvc.ClaimDelivery(ctx, order.ID, sellerID, "DIRECT_TRADE", []delivery.EvidenceInput{
		{
			MediaAssetID: uuid.New(),
			EvidenceType: "SCREENSHOT",
			Description:  "In-game trade window",
			Checksum:     "bad_hash", // Less than 32 chars
		},
	})
	if err == nil {
		t.Fatalf("expected error with invalid checksum, got nil")
	}

	// 5. Test: Valid delivery claim with SHA-256 evidence
	validSHA256 := "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
	del, err := delSvc.ClaimDelivery(ctx, order.ID, sellerID, "DIRECT_TRADE", []delivery.EvidenceInput{
		{
			MediaAssetID: uuid.New(),
			EvidenceType: "SCREENSHOT",
			Description:  "In-game trade accepted screenshot",
			Checksum:     validSHA256,
		},
	})
	if err != nil {
		t.Fatalf("ClaimDelivery failed: %v", err)
	}
	if del.Status != "DELIVERY_CLAIMED" {
		t.Fatalf("expected delivery status DELIVERY_CLAIMED, got %s", del.Status)
	}

	// Order must now be in DELIVERY_CLAIMED state
	updatedOrder, _ := ordSvc.GetOrder(order.ID)
	if updatedOrder.OrderStatus != domain.OrderStatusDeliveryClaimed {
		t.Fatalf("expected order status DELIVERY_CLAIMED, got %s", updatedOrder.OrderStatus)
	}

	// 6. Test: Unauthorized user cannot confirm delivery
	strangerID := uuid.New()
	err = delSvc.BuyerConfirm(ctx, order.ID, strangerID)
	if err == nil {
		t.Fatalf("expected forbidden error when stranger confirms delivery, got nil")
	}

	// 7. Buyer confirms delivery
	err = delSvc.BuyerConfirm(ctx, order.ID, buyerID)
	if err != nil {
		t.Fatalf("BuyerConfirm failed: %v", err)
	}

	finalOrder, _ := ordSvc.GetOrder(order.ID)
	if finalOrder.OrderStatus != domain.OrderStatusCompleted {
		t.Fatalf("expected order status COMPLETED, got %s", finalOrder.OrderStatus)
	}
}
