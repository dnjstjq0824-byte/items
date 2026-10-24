# 11. FLUTTER MOBILE SCREEN SPECIFICATION

**Document ID:** BN-DOC-011  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 30)  

---

## 1. Native Mobile Architecture (Android & iOS)
- Target: Flutter 3.27+ / Dart 3.6+
- Bottom Navigation Shell:
  - **Tab 1: Home** (`HomeScreen`) - Game-first exploration, featured pre-cleared games, compliance notice banner.
  - **Tab 2: Orders** (`OrdersScreen`) - Order cards, lifecycle status pill, evidence review container, dispute opener.
  - **Tab 3: Sell** (`SellerScreen`) - Seller profile, PRO_SELLER badge, pending balance, payout disbursement request.
  - **Tab 4: Chat** (`ChatScreen`) - Real-time WebSocket messaging, anti-phishing warning banner, price negotiation card.

---

## 2. In-App Payment Guardrail
Per Article 30, the mobile application does not expose unapproved external payment links. Checkout actions link exclusively to pre-approved licensed PSP webviews with strict policy checks in place.

