# BN GAMEEX — DEPENDENCIES AND BLOCKERS

**Updated:** 2026-10-24T22:37:00+09:00

## 1. External Compliance & Licensing Blockers (Intentional & Law-Mandated)

Per ARTICLE 0, 3, 16.1, and 37 of the Master PO Order:

| Feature Area | Live Trading Status | Technical Mock / Sandbox Status | Commercial Release Gate |
| :--- | :--- | :--- | :--- |
| **Live In-game Currency Trading** | **BLOCKED** | Modeled in schema; gated by `game_trade_policies.trade_enabled = false` | Requires explicit game publisher agreement & jurisdictional AML legal opinion |
| **Game Account Transfer** | **BLOCKED** | Disabled in v1.0 per Article 3.4; credentials collection strictly prohibited | Banned until official publisher-approved transfer API exists |
| **Live Customer Fund Custody** | **BLOCKED** | Direct wallet/custody disabled; only external PSP licensed escrow supported | Requires contracted regulated financial institution or PSP partner |
| **Live PSP Payment Processing** | **BLOCKED (Live)** / **READY (Sandbox)** | Standardized `PaymentProvider` adapter with functional mock sandbox | Live activation blocked until merchant acquiring contract signed and verified |
| **Live Seller Bank Payout** | **BLOCKED (Live)** / **READY (Sandbox)** | Standardized `PayoutProvider` adapter with mock payout batching | Live activation blocked until payout agreement and KYB approval |

> [!IMPORTANT]
> The above blocks are **by design** and represent strict legal gating mandated by PO Order BN-GAMEEX-MASTER-001. The platform handles these safely by marking them as `BLOCKED` in the release matrix while providing 100% operational Sandbox and policy-gated pipelines.

## 2. Infrastructure & Local Dependencies
- Local Go: `go1.27.0` (Ready)
- Local Node.js: `v24.19.0` with `npm 11.17.0` (Ready)
- Local Flutter: `3.47.8` / `Dart 3.13.7` (Ready)
- Database: Target PostgreSQL 16+. For automated local testing, Go unit tests utilize an in-memory SQL SQLite compatibility harness / driver or mock store while production SQL migrations are 100% standard PostgreSQL 16+ DDL with full UUID, TIMESTAMPTZ, and CHECK constraints.

