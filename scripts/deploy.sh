#!/usr/bin/env bash
# ==============================================================================
# BN GAMEEX — PRODUCTION SERVER DEPLOYMENT SCRIPT
# Ref: Master PO Order BN-GAMEEX-MASTER-001
# ==============================================================================

set -euo pipefail

echo "=========================================================="
echo "🌍 BN GAMEEX — COMMENCING PRODUCTION SERVER DEPLOYMENT"
echo "=========================================================="

# 1. Environment pre-flight check
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        echo "[DEPLOY] No .env found. Copying from .env.example..."
        cp .env.example .env
        echo "[DEPLOY:WARN] Please verify production secrets in .env!"
    else
        echo "[DEPLOY:ERROR] .env file is required for production deployment."
        exit 1
    fi
fi

# 2. Build and verify Go Binaries
echo "[DEPLOY:1/4] Compiling Go backend services..."
go build -ldflags="-w -s" -o bin/api ./services/api/cmd
go build -ldflags="-w -s" -o bin/worker ./services/worker/cmd
echo "[DEPLOY:1/4] Go binaries compiled successfully."

# 3. Build Admin Console (Vite / Vue 3)
echo "[DEPLOY:2/4] Building Admin Console bundle..."
(cd apps/admin && npm ci && npm run build)

# 4. Build Public Web App (Nuxt 3 SSR)
echo "[DEPLOY:3/4] Building Public Web bundle..."
(cd apps/web && npm ci && npm run build)

# 5. Launch Container Orchestration
echo "[DEPLOY:4/4] Launching Docker container stack..."
docker compose -f infrastructure/deploy/docker-compose.prod.yml up -d --build

echo "=========================================================="
echo "✅ BN GAMEEX PRODUCTION STACK DEPLOYED SUCCESSFULLY!"
echo "   Public Web:    http://localhost:80 (or http://localhost:3000)"
echo "   Admin Console: http://localhost:80/admin/ (or http://localhost:3001)"
echo "   API Gateway:   http://localhost:80/api/v1/"
echo "   Health Check:  http://localhost:80/healthz"
echo "=========================================================="

