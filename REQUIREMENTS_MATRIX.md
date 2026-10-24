# BN GAMEEX — MASTER REQUIREMENTS TRACEABILITY MATRIX

**Document ID:** BN-REQ-MATRIX-001  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001  

| Req ID | Article | Domain / Requirement | Acceptance Criteria & Policy Gate | Status |
| :--- | :--- | :--- | :--- | :--- |
| BN-REQ-001 | Art 0-1 | Global P2P Game Marketplace Vision | Game-first search, verified delivery evidence, transparent trade status | IN PROGRESS |
| BN-REQ-002 | Art 2 | Competitor Benchmarking | Real comparison of ItemMania, Eldorado, PlayerAuctions, G2G, FunPay, EpicNPC | IN PROGRESS |
| BN-REQ-003 | Art 3 | Global Product Policy & Legal Gate | Strict `Country + Game + Product Type` policy validation before listing/checkout | IMPLEMENTED |
| BN-REQ-004 | Art 3.4 | Game Account Trading Policy | Disabled by default in v1.0, password/recovery field collection banned | ENFORCED |
| BN-REQ-005 | Art 3.5 | Anti-Bot & No Unofficial Automation | Ban unofficial client manipulation, bots, memory scraping | ENFORCED |
| BN-REQ-006 | Art 4 | RBAC & User Personas | Guest, Buyer, Seller, Pro Seller, Support, Moderator, Finance Ops, Super Admin | IMPLEMENTED |
| BN-REQ-007 | Art 5-6 | Modular Monolith Architecture | Go REST API, WebSocket Gateway, Background Worker, PostgreSQL, Redis | IN PROGRESS |
| BN-REQ-008 | Art 7 | Global URL Structure & Locales | Language prefixes (`/ko/`, `/en/`, etc.) & `/admin/*` routing | DESIGNED |
| BN-REQ-009 | Art 8 | Master Design System | Dark #0B1020, Light #F8FAFC, Indigo #6366F1, Cyan #22D3EE, Responsive 320px-2560px | DESIGNED |
| BN-REQ-010 | Art 9 | Public Web Experience | Hero, game search, category filters, approved offers, buyer protection guides | IN PROGRESS |
| BN-REQ-011 | Art 10 | Game Catalog System | Game, Platform (PC/Mobile/Console), Region, Server, Trade Policies | IMPLEMENTED |
| BN-REQ-012 | Art 11 | Listing & Inventory System | Available, Reserved, Sold quantities; Atomic reservation; Auto-rollback on expiry | IMPLEMENTED |
| BN-REQ-013 | Art 12 | Search & Unit Price Comparison | Normalized unit price, multi-facet filtering, fee transparency | IMPLEMENTED |
| BN-REQ-014 | Art 13 | Seller Center & Dashboard | Listing management, orders, delivery evidence upload, payout status | IN PROGRESS |
| BN-REQ-015 | Art 14 | Real-time WebSocket Chat | Persistent DB + Outbox, ack, read receipts, price offers, privacy warnings | IMPLEMENTED |
| BN-REQ-016 | Art 15 | Order Lifecycle State Machine | Awaiting payment -> Confirmed -> Delivery Claimed -> Buyer Review -> Completed | IMPLEMENTED |
| BN-REQ-017 | Art 16.1 | Legal Custody Prohibition | No unauthorized direct holding of customer funds; licensed PSP partner required | ENFORCED |
| BN-REQ-018 | Art 16.2 | Payment Provider Adapter Interface | CreateCheckout, Capture, Refund, Webhook Verification, Sandbox Provider | IMPLEMENTED |
| BN-REQ-019 | Art 16.5 | Fee Engine | Dynamic fee policy table (Buyer Fee, Seller Fee, Payment Fee, Tax) | IMPLEMENTED |
| BN-REQ-020 | Art 16.6 | Internal Double-Entry Ledger | Balancing debits & credits, auditability, reconciliation against PSP reports | IMPLEMENTED |
| BN-REQ-021 | Art 17 | Delivery & Evidence System | Evidence uploads (screenshots/videos), integrity checksums, buyer review | IMPLEMENTED |
| BN-REQ-022 | Art 18 | Dispute Resolution & Escalation | Dispute reasons, evidence submission, admin review, partial/full refund requests | IMPLEMENTED |
| BN-REQ-023 | Art 19 | Seller Verification & Trust | Verification levels (KYC/KYB via partner), completion rates, ratings, badges | IMPLEMENTED |
| BN-REQ-024 | Art 20 | Fraud & Risk Engine | High-value order review, velocity checks, phishing/off-platform link detection | IMPLEMENTED |
| BN-REQ-025 | Art 21 | Localization & Multi-Currency | i18n locales, currencies (KRW, USD, EUR, JPY, GBP), minor unit calculations | IMPLEMENTED |
| BN-REQ-026 | Art 22 | PostgreSQL Master Data Model | UUID primary keys, TIMESTAMPTZ, minor units (BIGINT), foreign keys, CHECK constraints | IMPLEMENTED |
| BN-REQ-027 | Art 23 | Database Integrity Invariants | `available + reserved <= total`, `refund <= captured`, idempotency keys | IMPLEMENTED |
| BN-REQ-028 | Art 24-25 | REST API Contracts & Endpoints | Public, Buyer, Seller, Delivery, Dispute, Review, Checkout endpoints | IMPLEMENTED |
| BN-REQ-029 | Art 26 | Payment Webhook Security | HMAC/Signature verification, replay prevention, idempotency table | IMPLEMENTED |
| BN-REQ-030 | Art 27-28 | Admin Console & Operations | Full back-office for catalog, policies, orders, payments, payouts, reconciliation | IN PROGRESS |
| BN-REQ-031 | Art 29 | Admin Dual-Approval (4-Eyes) | Two-person authorization for large refunds and seller payout execution | IMPLEMENTED |
| BN-REQ-032 | Art 30 | Flutter Mobile App (Android/iOS) | Clean architecture, Dart, local secure storage, WebSocket, checkout policy guard | IN PROGRESS |
| BN-REQ-033 | Art 31 | Security & PCI Compliance | No raw card storage, strict CSP, rate limiting, malware scan flag, audit logs | ENFORCED |
| BN-REQ-034 | Art 32 | E2E Test Matrix (63 Scenarios) | Automated tests covering account, catalog, seller, order, settlement, dispute | IN PROGRESS |
| BN-REQ-035 | Art 33 | Observability & Telemetry | Structured logging, metrics, dead-letter outbox, circuit breaker readiness | IMPLEMENTED |
| BN-REQ-036 | Art 34 | CI/CD & Provenance | GitHub Actions CI pipeline, Docker multistage builds | IMPLEMENTED |
| BN-REQ-037 | Art 35 | Phased Delivery Roadmap | Phase 0 to Phase 11 tracking | IN PROGRESS |
| BN-REQ-038 | Art 36 | 37 Mandatory Technical Documents | All documentation generated with complete traceability | IN PROGRESS |
| BN-REQ-039 | Art 37 | Release Acceptance Matrix | Real validation: Approved Live vs Blocked Sandbox distinction | IN PROGRESS |
| BN-REQ-040 | Art 39 | 24 Absolute Prohibitions | Complete guardrails enforced in code, database, and operational architecture | ENFORCED |

