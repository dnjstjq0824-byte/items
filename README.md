# 🌍 BN GAMEEX — Global Game Asset Trading Marketplace

**Trade Smarter. Game Further.**

BN GAMEEX is an enterprise-grade digital gaming asset and in-game item marketplace engineered under Master Requirements Document **BN-GAMEEX-MASTER-001**.

---

## 🏗️ Architecture & Component Overview

```
                                  ┌──────────────────────────┐
                                  │      Cloudflare Edge     │
                                  │ (Workers & Static Assets)│
                                  └─────────────┬────────────┘
                                                │
                        ┌───────────────────────┴───────────────────────┐
                        │                                               │
                        ▼                                               ▼
         ┌──────────────────────────────┐                ┌──────────────────────────────┐
         │          Public Web          │                │        Admin Console         │
         │      (Vue 3 / Nuxt 3)        │                │     (Vue 3 / Vite / TS)      │
         └──────────────┬───────────────┘                └──────────────┬───────────────┘
                        │                                               │
                        └───────────────────────┬───────────────────────┘
                                                │ REST / WSS
                                                ▼
                                 ┌──────────────────────────────┐
                                 │        Go API Backend        │
                                 │   (Policy, Orders, Ledger)   │
                                 └──────────────┬───────────────┘
                                                │
                                                ▼
                                 ┌──────────────────────────────┐
                                 │    PostgreSQL 16+ Database   │
                                 │   (34 Relational Tables)     │
                                 └──────────────────────────────┘
```

### 1. Core Applications
* **Public Web (`apps/web`):** Nuxt 3, Vue 3, Tailwind CSS, SSR & Pre-rendered Static Pages.
  * Approved Games Catalog (`/games`)
  * Item & Currency Listings (`/listings/:id`)
  * Master Order Tracking & Lifecycle Stepper (`/my/orders`)
  * Cryptographic SHA-256 Proof of Delivery Viewer (`/my/orders/:id`)
  * Seller Operations Center (`/seller/dashboard`)
  * Transparent 0% Buyer Fee Architecture & Calculator (`/fees`)
  * Buyer & Seller Escrow Protection System (`/help/trade-protection`)
  * In-App Secure Trade Chat with Anti-Leak Heuristics (`/chat`)
* **Admin Operations Console (`apps/admin`):** Vue 3, Vite, Pinia, TypeScript.
  * 9 Operations Centers: Overview, Trade Policies (Article 3), Master Order Ledger, Seller KYC, 4-Eyes Dispute Center, Double-Entry Reconciliation, Payment Webhooks, Anti-Fraud Surveillance, and Immutable Audit Logs.
* **Native Mobile Apps (`apps/mobile`):** Flutter 3.27+, Dart 3.6+ for Android and iOS with clean architecture and interactive trade escrow dialogs.
* **Backend API & Worker (`services/api`, `services/worker`):**
  * Multi-Gate Compliance Policy Engine (Article 3 & strict Article 3.4 Game Account Trading ban)
  * Atomic Inventory Reservation with TTL auto-rollback
  * 14-State Deterministic Order State Machine
  * Double-Entry Financial Accounting Ledger ($\sum \text{Debit} == \sum \text{Credit}$)
  * Cryptographic SHA-256 Delivery Evidence Verification
  * 4-Eyes Dual Approval Dispute Resolution System
  * Anti-Fraud Heuristic Surveillance Engine

---

## ⚡ Cloudflare Automatic Deployment

This repository is integrated with **Cloudflare Workers Static Assets & Pages**:
* Root [`wrangler.toml`](wrangler.toml) configures static asset hosting from `public/`.
* Root [`worker.js`](worker.js) provides Single Page Application (SPA) fallback routing.
* Every commit automatically triggers Cloudflare CI/CD to build and deploy.

### Manual Cloudflare Deployment
```bash
npx wrangler deploy
```

---

## 🧪 Testing & Verification

```bash
# Backend Go Tests (100% PASS across all 8 internal packages)
cd services/api && go test -v ./...

# Public Web Production Build
cd apps/web && npm run generate

# Admin Console Build
cd apps/admin && npm run build

# Mobile Flutter Analyzer
cd apps/mobile && flutter analyze
```

---

## 📜 Compliance & Safety Invariants
1. **Article 3.4 Banned Account Trading:** Unconditionally enforced across policy engine, database schemas, and user interfaces.
2. **Zero Custody of Customer Funds:** BN GAMEEX never holds fiat customer balances; delegates directly to licensed external payment rail vaults.
3. **Double-Entry Financial Accounting:** Every monetary movement requires balanced debit and credit entries.
4. **4-Eyes Principle:** High-value dispute refunds require secondary authentication by an independent finance approver.

