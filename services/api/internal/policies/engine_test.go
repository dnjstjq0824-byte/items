package policies_test

import (
	"context"
	"testing"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/policies"
	"github.com/google/uuid"
)

func TestPolicyEngine_EnforcesComplianceGate(t *testing.T) {
	eng := policies.NewPolicyEngine()
	gameID := uuid.New()

	// 1. Register approved policy for US + GAME_ITEM
	eng.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                gameID,
		CountryCode:           "US",
		ProductType:           domain.ProductTypeGameItem,
		LegalReviewStatus:     "APPROVED",
		PublisherPolicyStatus: "PERMITTED",
		PaymentPartnerStatus:  "APPROVED",
		TradeEnabled:          true,
	})

	// 2. Register non-approved policy for KR + GAME_CURRENCY (Article 3.3 compliance gate)
	eng.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                gameID,
		CountryCode:           "KR",
		ProductType:           domain.ProductTypeGameCurrency,
		LegalReviewStatus:     "REVIEW_REQUIRED",
		PublisherPolicyStatus: "REVIEW_REQUIRED",
		PaymentPartnerStatus:  "PENDING",
		TradeEnabled:          false,
	})

	ctx := context.Background()

	// Test 1: Approved Item in US should succeed
	if err := eng.ValidateTrade(ctx, gameID, "US", domain.ProductTypeGameItem); err != nil {
		t.Fatalf("expected approved trade to pass, got: %v", err)
	}

	// Test 2: Gated Currency in KR should fail with ErrPolicyProhibited
	if err := eng.ValidateTrade(ctx, gameID, "KR", domain.ProductTypeGameCurrency); err == nil {
		t.Fatalf("expected currency trade pending review to be blocked, but it passed")
	}

	// Test 3: Article 3.4 Absolute Prohibition - Game Account must be blocked unconditionally
	if err := eng.ValidateTrade(ctx, gameID, "US", domain.ProductTypeGameAccount); err != domain.ErrAccountTradeProhibited {
		t.Fatalf("expected ErrAccountTradeProhibited, got: %v", err)
	}

	// Test 4: Unknown country/policy should be blocked
	if err := eng.ValidateTrade(ctx, gameID, "DE", domain.ProductTypeGameItem); err == nil {
		t.Fatalf("expected unconfigured policy to be blocked")
	}
}
