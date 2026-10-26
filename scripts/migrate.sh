#!/usr/bin/env bash
# ==============================================================================
# BN GAMEEX — DATABASE MIGRATION SCRIPT
# Ref: Master PO Order BN-GAMEEX-MASTER-001 (Article 22)
# ==============================================================================

set -euo pipefail

DB_URL="${DATABASE_URL:-postgres://gameex_user:secure_prod_password_2026@localhost:5432/bn_gameex?sslmode=disable}"

echo "[MIGRATE] Connecting to PostgreSQL at ${DB_URL%@*}@..."

# Run Master Schema
echo "[MIGRATE:1/2] Applying 001_initial_schema.sql..."
psql "$DB_URL" -f database/migrations/001_initial_schema.sql

# Run Canonical Fixtures
echo "[MIGRATE:2/2] Applying canonical seed fixtures..."
for f in database/fixtures/*.sql; do
    echo "  Applying $f..."
    psql "$DB_URL" -f "$f"
done

echo "[MIGRATE] ✅ All migrations and seed fixtures applied successfully."

