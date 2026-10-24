package payment_test

import (
	"encoding/json"
	"testing"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/payment"
)

func TestPaymentProvider_HMACVerificationAndIdempotency(t *testing.T) {
	secret := "test_secret_key_123"
	psp := payment.NewSandboxPaymentProvider("stripe_sandbox", secret)

	payloadObj := payment.WebhookEventDTO{
		EventID:                  "evt_test_unique_001",
		EventType:                "payment.succeeded",
		ProviderPaymentReference: "sbx_pay_ref_001",
		AmountMinor:              5000,
		CurrencyCode:             "USD",
	}

	payloadBytes, err := json.Marshal(payloadObj)
	if err != nil {
		t.Fatalf("failed to marshal payload: %v", err)
	}

	// 1. Sign correctly
	validSig := psp.SignPayload(payloadBytes)
	if err := psp.VerifyWebhookSignature(payloadBytes, validSig); err != nil {
		t.Fatalf("expected valid signature to pass, got: %v", err)
	}

	// 2. Tampered signature should fail (Article 26)
	invalidSig := "tampered_bad_signature"
	if err := psp.VerifyWebhookSignature(payloadBytes, invalidSig); err != domain.ErrInvalidWebhookSignature {
		t.Fatalf("expected ErrInvalidWebhookSignature, got: %v", err)
	}

	// 3. Process event once
	event, err := psp.ParseWebhookEvent(payloadBytes)
	if err != nil {
		t.Fatalf("expected event parsing to succeed, got: %v", err)
	}
	if event.ProviderEventID != "evt_test_unique_001" {
		t.Fatalf("unexpected event ID: %s", event.ProviderEventID)
	}

	// 4. Replay attack with same EventID must be rejected (Article 26 & 23)
	_, err = psp.ParseWebhookEvent(payloadBytes)
	if err != domain.ErrIdempotencyConflict {
		t.Fatalf("expected replay event to be rejected with ErrIdempotencyConflict, got: %v", err)
	}
}
