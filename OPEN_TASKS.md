# BN GAMEEX — OPEN TASKS & COMMERCIAL RELEASE GATES

**Updated:** 2026-10-26T15:04:00+09:00

## 1. Technical Development & Turnkey Readiness
- [x] All 11 phases of technical engineering order BN-GAMEEX-MASTER-001 completed.
- [x] Full-stack self-audit conducted across Go backend, PostgreSQL, Vue Web/Admin, and Flutter mobile (100% PASS).
- [x] Production Docker Compose, Nginx reverse proxy, and Kubernetes manifests deployed in `infrastructure/deploy/`.
- [x] Automated deployment scripts ready in `scripts/` (`deploy.sh`, `deploy.ps1`, `migrate.sh`, `healthcheck.sh`).
- [x] Production environment template `.env.example` completed.

## 2. Mandatory Commercial Production Release Gates (Awaiting Formal PO Onboarding)
- [ ] **Gate 1: Live Merchant Acquiring Contract:** Live external PSP keys to replace functional Sandbox adapter once countersigned agreement is finalized.
- [ ] **Gate 2: Live Payout Bank Agreement:** Live bulk disbursement provider credentials once corporate KYB onboarding completes.
- [ ] **Gate 3: Jurisdictional Game Currency Legal Opinion:** Retained counsel review before changing `game_trade_policies.trade_enabled` from `FALSE` to `TRUE` for Korean in-game currencies.
- [ ] **Gate 4: Final Product Owner Commercial Signoff:** Explicit PO authorization to transition deployment from Pre-Release Staging to Live Production.
