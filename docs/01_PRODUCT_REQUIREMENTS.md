# 01. PRODUCT REQUIREMENTS DOCUMENT (PRD)

**Document ID:** BN-DOC-001  
**Product Name:** BN GAMEEX (가칭)  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001  
**Classification:** Core Governance & Requirements Specification  

---

## 1. Product Vision & Principles
BN GAMEEX is a global peer-to-peer (P2P) gaming digital asset trading platform engineered to bring verified trust, cryptographic evidence, and strict legal compliance to gaming transactions worldwide.

### Core Principles
1. **Compliance Before Live Trading:** No game items, game currency, or vouchers are made live without formal publisher TOS alignment, jurisdictional legal review, and payment partner underwriting.
2. **Zero Custody of Customer Funds:** BN GAMEEX never holds unregulated customer fiat funds. All fund movements and split payouts are orchestrated through licensed external payment service providers (PSPs).
3. **Evidence-Based Delivery:** Orders require sellers to submit verifiable proof of delivery (SHA-256 hashed screenshots, logs, or API callbacks) before buyer confirmation or automatic protection release.
4. **Transparent Economics:** No hidden fees. Every quote explicitly itemizes subtotal, buyer fees, seller fees, payment processing fees, and applicable taxes.

---

## 2. Target Platforms & Tech Stack
- **Public Web:** Vue 3 / Nuxt / TypeScript (SSR, i18n, dark/light theme)
- **Admin Console:** Vue 3 / Vite / TypeScript / Pinia / RBAC
- **Mobile Applications:** Flutter (Dart) native builds for Android & iOS
- **Backend Services:** Go 1.24+ modular microservices / REST API & WebSocket Gateway
- **Persistence & Cache:** PostgreSQL 16+ (master relational data model) & Redis 7 (caching/pubsub)

---

## 3. Product Scope Breakdown
- **Game Catalog Management:** Games, platforms, regions, servers, and allowed product types.
- **Listing & Inventory System:** Available, reserved, and sold quantities with atomic reservation semantics.
- **Search & Comparison Engine:** Multi-facet filtering and normalized unit price comparisons.
- **Real-Time Communication:** Persistent WebSocket chat with automated risk/phishing heuristics.
- **Order Lifecycle Engine:** 14-state deterministic order state machine.
- **Payment & Settlement Integration:** Standardized PaymentProvider & PayoutProvider adapter architectures.
- **Internal Double-Entry Ledger:** Audit trail reconciling debits and credits against external PSP settlement batches.
- **Delivery & Dispute Resolution:** Evidence-backed delivery confirmation with dual-approval (4-eyes) refund mechanics.
