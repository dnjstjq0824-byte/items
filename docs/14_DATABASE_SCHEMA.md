# 14. DATABASE SCHEMA DOCUMENTATION

**Document ID:** BN-DOC-014  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 22 & 23)  

---

## 1. Relational Entities Summary (PostgreSQL 16+)
The master database consists of 34 normalized tables across 14 functional domains:
1. **Identity:** `users`, `user_sessions`, `user_preferences`, `user_blocks`.
2. **Media:** `media_assets`.
3. **Game Catalog:** `games`, `game_platforms`, `game_regions`, `game_servers`, `game_product_types`, `game_trade_policies`, `game_policy_sources`.
4. **Sellers:** `sellers`, `seller_verifications`, `seller_payout_accounts`.
5. **Listings & Stock:** `listings`, `listing_images`, `listing_attributes`, `listing_status_history`, `listing_favorites`, `inventory_reservations`.
6. **Orders:** `order_quotes`, `orders`, `order_status_history`, `order_fees`, `price_negotiations`.
7. **Chat:** `conversations`, `conversation_participants`, `chat_messages`, `chat_attachments`.
8. **Payments:** `payment_providers`, `payment_intents`, `payment_events`, `refunds`, `chargebacks`.
9. **Ledger:** `ledger_accounts`, `ledger_transactions`, `ledger_entries`, `payout_requests`, `settlement_batches`, `reconciliation_items`.
10. **Delivery:** `deliveries`, `delivery_evidence`, `delivery_reviews`.
11. **Disputes:** `disputes`, `dispute_evidence`, `dispute_decisions`, `dispute_appeals`.
12. **Trust & Risk:** `seller_reviews`, `risk_events`, `risk_decisions`.
13. **Support & CMS:** `support_tickets`, `support_messages`, `articles`.
14. **System & Admin:** `admin_roles`, `admin_permissions`, `admin_user_roles`, `audit_logs`, `country_compliance_policies`, `fee_policies`, `feature_flags`, `outbox_events`.

---

## 2. Hard Database Constraints & Invariants
- All monetary amounts stored as `BIGINT` in minor units (cents, KRW).
- UUID primary keys generated via `gen_random_uuid()`.
- Check constraints:
  - `CHECK (available_quantity >= 0 AND reserved_quantity >= 0)`
  - `CHECK (debit_minor >= 0 AND credit_minor >= 0)`
  - `CHECK (NOT (debit_minor > 0 AND credit_minor > 0))`
  - `CHECK (blocker_user_id <> blocked_user_id)`

