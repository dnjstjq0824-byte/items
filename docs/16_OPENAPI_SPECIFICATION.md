# 16. OPENAPI 3.1 REST SPECIFICATION REFERENCE

**Document ID:** BN-DOC-016  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 24, 25, 26)  

---

## 1. Specification Artifact
The canonical OpenAPI 3.1.0 contract is defined in [contracts/openapi/openapi.yaml](file:///contracts/openapi/openapi.yaml).

## 2. Key Endpoint Groups
- `GET /api/v1/games`: Retrieve supported game list.
- `GET /api/v1/games/{id}/trade-availability`: Multi-gate compliance check for specified country and product type.
- `GET /api/v1/listings/search`: Faceted item exploration with price comparison.
- `POST /api/v1/orders/quotes`: Generate immutable quote with fee and tax breakdown.
- `POST /api/v1/orders`: Atomic inventory hold and order placement.
- `POST /api/v1/orders/{id}/checkout`: Dispatch checkout session to external licensed PSP.
- `POST /api/v1/integrations/payments/{provider}/webhooks`: Inbound HMAC-verified payment status webhook.
- `POST /api/v1/orders/{id}/delivery`: Seller fulfillment submission with cryptographic evidence.
- `POST /api/v1/orders/{id}/buyer-confirm`: Buyer confirmation and payout release trigger.
- `POST /api/v1/orders/{id}/disputes`: Formal dispute initialization.
- `GET /api/v1/admin/dashboard`: Segregated operational metrics.
- `POST /api/v1/admin/disputes/decisions/{id}/approve`: 4-Eyes secondary approval for refund execution.
