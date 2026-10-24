# 35. REQUIREMENTS TRACEABILITY REGISTER

**Document ID:** BN-DOC-035  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 35 & 38)  

---

## 1. Traceability Mapping

| Master PO Req | Code Location / Implementation Artifact | Verification Test | Status |
| :--- | :--- | :--- | :--- |
| **Article 3 (Policy Gate)** | `services/api/internal/policies/engine.go` | `engine_test.go` | **IMPLEMENTED** |
| **Article 3.4 (Account Trade Ban)**| `domain.ErrAccountTradeProhibited` in policy engine | `engine_test.go` | **ENFORCED** |
| **Article 8 (Design System)** | `apps/web/assets/css/main.css`, `apps/mobile/lib/core/theme/` | UI Build & Inspect | **IMPLEMENTED** |
| **Article 11 (Inventory Invariants)**| `services/api/internal/inventory/service.go` | `service_test.go` | **IMPLEMENTED** |
| **Article 14 (WebSocket Chat)** | `services/api/internal/chat/gateway.go` | WS Handshake Test | **IMPLEMENTED** |
| **Article 15 (State Machine)** | `services/api/internal/orders/service.go` | Order Lifecycle Test | **IMPLEMENTED** |
| **Article 16.2 (Payment Adapter)** | `services/api/internal/payment/provider.go` | `provider_test.go` | **IMPLEMENTED** |
| **Article 16.6 (Double-Entry Ledger)**| `services/api/internal/ledger/service.go` | `ledger_test.go` | **IMPLEMENTED** |
| **Article 17 (Delivery Proof)** | `services/api/internal/delivery/service.go` | Delivery Claim Test | **IMPLEMENTED** |
| **Article 18 (Dispute Dual-Approval)**| `services/api/internal/disputes/service.go` | `disputes_test.go` | **IMPLEMENTED** |
| **Article 20 (Fraud & Risk)** | `services/api/internal/risk/engine.go` | Phishing/Leak Test | **IMPLEMENTED** |
| **Article 22 (PostgreSQL DDL)** | `database/migrations/001_initial_schema.sql` | SQL Syntax / Test | **IMPLEMENTED** |
| **Article 27 (Admin Operations)** | `apps/admin/src/` | Vite Build Test | **IMPLEMENTED** |
| **Article 30 (Flutter Native App)**| `apps/mobile/lib/` | Flutter Analyze | **IMPLEMENTED** |
