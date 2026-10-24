package payment

import (
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/google/uuid"
)

type CheckoutResult struct {
	CheckoutURL              string    `json:"checkout_url"`
	ProviderPaymentReference string    `json:"provider_payment_reference"`
	ExpiresAt                time.Time `json:"expires_at"`
}

type RefundResult struct {
	ProviderRefundReference string    `json:"provider_refund_reference"`
	Status                  string    `json:"status"`
	CompletedAt             time.Time `json:"completed_at"`
}

// PaymentProvider defines the adapter interface per Article 16.2
type PaymentProvider interface {
	GetProviderID() string
	CreateCheckout(ctx context.Context, order *domain.Order, returnURL, cancelURL string) (*CheckoutResult, error)
	VerifyWebhookSignature(payload []byte, signatureHeader string) error
	ParseWebhookEvent(payload []byte) (*domain.PaymentEvent, error)
	RefundPayment(ctx context.Context, intent *domain.PaymentIntent, amountMinor int64, reason string) (*RefundResult, error)
}

// SandboxPaymentProvider implements a secure, verifiable sandbox adapter
type SandboxPaymentProvider struct {
	providerID     string
	webhookSecret  string
	mu             sync.Mutex
	intents        map[string]*domain.PaymentIntent
	processedEvents map[string]bool
}

func NewSandboxPaymentProvider(providerID, webhookSecret string) *SandboxPaymentProvider {
	return &SandboxPaymentProvider{
		providerID:     providerID,
		webhookSecret:  webhookSecret,
		intents:        make(map[string]*domain.PaymentIntent),
		processedEvents: make(map[string]bool),
	}
}

func (p *SandboxPaymentProvider) GetProviderID() string {
	return p.providerID
}

func (p *SandboxPaymentProvider) CreateCheckout(ctx context.Context, order *domain.Order, returnURL, cancelURL string) (*CheckoutResult, error) {
	p.mu.Lock()
	defer p.mu.Unlock()

	ref := fmt.Sprintf("sbx_pay_%s_%d", order.ID.String()[:8], time.Now().UnixNano())
	checkoutURL := fmt.Sprintf("https://sandbox-checkout.bookingnetwork.example/pay/%s?ret=%s", ref, returnURL)

	intent := &domain.PaymentIntent{
		ID:                       uuid.New(),
		OrderID:                  order.ID,
		ProviderID:               p.providerID,
		ProviderPaymentReference: ref,
		AmountMinor:              order.TotalMinor,
		CurrencyCode:             order.CurrencyCode,
		Status:                   domain.PaymentStatusCheckoutCreated,
		IdempotencyKey:           order.ID.String(),
		CheckoutURL:              checkoutURL,
		CreatedAt:                time.Now(),
		UpdatedAt:                time.Now(),
	}

	p.intents[ref] = intent

	return &CheckoutResult{
		CheckoutURL:              checkoutURL,
		ProviderPaymentReference: ref,
		ExpiresAt:                time.Now().Add(30 * time.Minute),
	}, nil
}

// SignPayload generates valid HMAC-SHA256 signature for test harness
func (p *SandboxPaymentProvider) SignPayload(payload []byte) string {
	mac := hmac.New(sha256.New, []byte(p.webhookSecret))
	mac.Write(payload)
	return hex.EncodeToString(mac.Sum(nil))
}

// VerifyWebhookSignature verifies HMAC-SHA256 signature to prevent unauthorized tampering (Article 26)
func (p *SandboxPaymentProvider) VerifyWebhookSignature(payload []byte, signatureHeader string) error {
	expectedSignature := p.SignPayload(payload)
	if !hmac.Equal([]byte(expectedSignature), []byte(signatureHeader)) {
		return domain.ErrInvalidWebhookSignature
	}
	return nil
}

type WebhookEventDTO struct {
	EventID                  string `json:"event_id"`
	EventType                string `json:"event_type"`
	ProviderPaymentReference string `json:"provider_payment_reference"`
	AmountMinor              int64  `json:"amount_minor"`
	CurrencyCode             string `json:"currency_code"`
}

func (p *SandboxPaymentProvider) ParseWebhookEvent(payload []byte) (*domain.PaymentEvent, error) {
	var dto WebhookEventDTO
	if err := json.Unmarshal(payload, &dto); err != nil {
		return nil, fmt.Errorf("malformed webhook payload: %w", err)
	}

	p.mu.Lock()
	defer p.mu.Unlock()

	// Idempotency: Prevent replay attacks (Article 26 & 23)
	if p.processedEvents[dto.EventID] {
		return nil, domain.ErrIdempotencyConflict
	}
	p.processedEvents[dto.EventID] = true

	var intentID *uuid.UUID
	if intent, ok := p.intents[dto.ProviderPaymentReference]; ok {
		intentID = &intent.ID
		if dto.EventType == "payment.succeeded" {
			intent.Status = domain.PaymentStatusCaptured
			intent.UpdatedAt = time.Now()
		}
	}

	now := time.Now()
	event := &domain.PaymentEvent{
		ID:              uuid.New(),
		ProviderID:      p.providerID,
		ProviderEventID: dto.EventID,
		PaymentIntentID: intentID,
		EventType:       dto.EventType,
		Payload:         string(payload),
		Status:          "PROCESSED",
		ProcessedAt:     &now,
		CreatedAt:       now,
	}

	return event, nil
}

func (p *SandboxPaymentProvider) RefundPayment(ctx context.Context, intent *domain.PaymentIntent, amountMinor int64, reason string) (*RefundResult, error) {
	p.mu.Lock()
	defer p.mu.Unlock()

	if intent.Status != domain.PaymentStatusCaptured {
		return nil, fmt.Errorf("cannot refund uncaptured payment (status: %s)", intent.Status)
	}

	ref := fmt.Sprintf("sbx_ref_%s_%d", intent.ID.String()[:8], time.Now().UnixNano())
	return &RefundResult{
		ProviderRefundReference: ref,
		Status:                  "COMPLETED",
		CompletedAt:             time.Now(),
	}, nil
}

