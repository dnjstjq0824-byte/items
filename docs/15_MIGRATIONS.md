# 15. MIGRATIONS RUNBOOK & VERIFICATION

**Document ID:** BN-DOC-015  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 22 & 34)  

---

## 1. Migration Execution Order
Database migrations are strictly sequential and version-controlled under `database/migrations/`:

1. `001_initial_schema.sql`: Authorizes `pgcrypto` and `uuid-ossp` extensions; provisions all 34 relational tables, foreign key constraints, default timestamps, unique indexes, and domain CHECK constraints.
2. `fixtures/01_admin_roles.sql`: Seeds canonical roles (SUPER_ADMIN to READ_ONLY_AUDITOR) and granular resource permissions.
3. `fixtures/02_games_catalog.sql`: Seeds initial pre-cleared games, platforms, regions, and servers.
4. `fixtures/03_trade_policies.sql`: Seeds multi-gate compliance policy entries.
5. `fixtures/04_fee_policies.sql`: Provisions standard platform commission rates.
6. `fixtures/05_ledger_accounts.sql`: Generates standard chart of accounts for double-entry reconciliation.

---

## 2. Rollback & Disaster Recovery
- All migrations are idempotent using `IF NOT EXISTS` and `ON CONFLICT DO NOTHING`.
- Point-in-time recovery (PITR) enabled via continuous WAL archiving on production clusters.
