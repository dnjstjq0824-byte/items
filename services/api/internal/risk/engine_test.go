package risk_test

import (
	"context"
	"testing"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/risk"
	"github.com/google/uuid"
)

func TestRiskEngine_EvaluateMessageContent(t *testing.T) {
	ctx := context.Background()
	engine := risk.NewEngine()
	userID := uuid.New()

	// 1. Phishing Attempt
	action, err := engine.EvaluateMessageContent(ctx, userID, "Click here to claim free skins: https://steamcommunlty.com/gift")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if action != "BLOCK" {
		t.Fatalf("expected action BLOCK for phishing URL, got %s", action)
	}

	// 2. Off-platform leak attempt
	action, err = engine.EvaluateMessageContent(ctx, userID, "Add me on telegram t.me/darktrader to pay with crypto")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if action != "WARNING" {
		t.Fatalf("expected action WARNING for off-platform leak, got %s", action)
	}

	// 3. Normal in-game handover message
	action, err = engine.EvaluateMessageContent(ctx, userID, "I am waiting at Lioneye's Watch waypoint on channel 2")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if action != "ALLOW" {
		t.Fatalf("expected action ALLOW for legitimate message, got %s", action)
	}
}

func TestRiskEngine_EvaluateOrderRisk(t *testing.T) {
	ctx := context.Background()
	engine := risk.NewEngine()

	// 1. High value order with unverified seller
	unverifiedSeller := &domain.Seller{
		ID:                 uuid.New(),
		UserID:             uuid.New(),
		SellerType:         "STANDARD",
		VerificationStatus: "UNVERIFIED",
		SalesStatus:        "ACTIVE",
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}
	action, err := engine.EvaluateOrderRisk(ctx, unverifiedSeller, 150000, "USD") // $1,500
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if action != "MANUAL_REVIEW" {
		t.Fatalf("expected MANUAL_REVIEW for high-value unverified seller, got %s", action)
	}

	// 2. Banned seller
	bannedSeller := &domain.Seller{
		ID:                 uuid.New(),
		UserID:             uuid.New(),
		SellerType:         "STANDARD",
		VerificationStatus: "VERIFIED",
		SalesStatus:        "BANNED",
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}
	action, err = engine.EvaluateOrderRisk(ctx, bannedSeller, 5000, "USD")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if action != "BLOCK" {
		t.Fatalf("expected BLOCK for banned seller, got %s", action)
	}

	// 3. Normal verified seller
	verifiedSeller := &domain.Seller{
		ID:                 uuid.New(),
		UserID:             uuid.New(),
		SellerType:         "PRO",
		VerificationStatus: "VERIFIED",
		SalesStatus:        "ACTIVE",
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}
	action, err = engine.EvaluateOrderRisk(ctx, verifiedSeller, 200000, "USD")
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if action != "ALLOW" {
		t.Fatalf("expected ALLOW for verified seller, got %s", action)
	}
}
