#!/usr/bin/env bash
# ==============================================================================
# BN GAMEEX — PRODUCTION HEALTHCHECK VERIFICATION SCRIPT
# Ref: Master PO Order BN-GAMEEX-MASTER-001 (Article 33)
# ==============================================================================

set -euo pipefail

TARGET_HOST="${1:-http://localhost:8080}"

echo "[HEALTHCHECK] Probing $TARGET_HOST/healthz..."
curl -fsSL "$TARGET_HOST/healthz"
echo ""

echo "[HEALTHCHECK] Probing $TARGET_HOST/readyz..."
curl -fsSL "$TARGET_HOST/readyz"
echo ""

echo "[HEALTHCHECK] Probing $TARGET_HOST/api/v1/health..."
curl -fsSL "$TARGET_HOST/api/v1/health"
echo ""

echo "✅ All health endpoints responded successfully."

