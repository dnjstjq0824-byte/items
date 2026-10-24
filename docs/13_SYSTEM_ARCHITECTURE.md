# 13. SYSTEM ARCHITECTURE

**Document ID:** BN-DOC-013  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 5)  

---

## 1. High-Level Architecture Diagram

```mermaid
graph TD
    subgraph Clients["Clients Layer"]
        Web["Vue 3 / Nuxt Web"]
        Admin["Vue 3 Admin Console"]
        Mobile["Flutter App (Android/iOS)"]
    end

    subgraph Gateway["Edge & Gateway"]
        Nginx["Reverse Proxy / TLS 1.3"]
        WS["WebSocket Gateway"]
        REST["REST API Router"]
    end

    subgraph Services["Core Go Backend (Modular Monolith)"]
        PolicyEngine["Policy & Compliance Engine"]
        InvService["Inventory & Reservation Engine"]
        OrderService["Order State Machine Engine"]
        LedgerService["Double-Entry Financial Ledger"]
        DeliveryService["Evidence & Fulfillment Service"]
        DisputeService["Dispute & Dual-Approval Service"]
        RiskEngine["Fraud & Risk Engine"]
    end

    subgraph Data["Persistence & Event Bus"]
        PG[("PostgreSQL 16 Master DB")]
        Redis[("Redis 7 Cache / PubSub")]
        Storage["S3-Compatible Object Storage"]
    end

    subgraph External["External Partners"]
        PSP["Licensed Payment Service Provider"]
        Payout["External Payout Gateway"]
    end

    Clients --> Nginx
    Nginx --> REST
    Nginx --> WS
    
    REST --> Services
    WS --> Services
    
    Services --> PG
    Services --> Redis
    Services --> Storage
    
    OrderService --> PSP
    LedgerService --> Payout
```

---

## 2. Security Boundaries & Zero-Trust Invariants
1. **Network Isolation:** Database and internal services are only accessible from backend container networks.
2. **Idempotency Enforcement:** All order creation, payment capture, and refund webhooks require unique idempotency keys.
3. **No Direct Ledger Tampering:** Database balance columns cannot be manually incremented; all adjustments must originate from a verified balanced double-entry transaction.

