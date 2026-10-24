# 20. PAYMENT INTEGRATION & WEBHOOKS

**Document ID:** BN-DOC-020  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 16 & 26)  

---

## 1. Provider Adapter Architecture
The backend integrates with external payment gateways via the standardized `PaymentProvider` interface:

```go
type PaymentProvider interface {
    GetProviderID() string
    CreateCheckout(ctx context.Context, order *domain.Order, returnURL, cancelURL string) (*CheckoutResult, error)
    VerifyWebhookSignature(payload []byte, signatureHeader string) error
    ParseWebhookEvent(payload []byte) (*domain.PaymentEvent, error)
    RefundPayment(ctx context.Context, intent *domain.PaymentIntent, amountMinor int64, reason string) (*RefundResult, error)
}
```

---

## 2. Inbound Webhook Security Checklist
1. **Signature Verification:** Recomputes HMAC-SHA256 of payload against registered webhook secret.
2. **Replay Protection:** Deduplicates incoming `provider_event_id` against the `payment_events` table before processing.
3. **Amount Matching:** Verifies captured amount and currency match the order record exactly.
4. **Asynchronous Outbox:** Updates order state in database and emits transactional outbox event for fulfillment dispatch.
