# ==============================================================================
# BN GAMEEX — WINDOWS PRODUCTION & STAGING DEPLOYMENT SCRIPT
# Ref: Master PO Order BN-GAMEEX-MASTER-001
# ==============================================================================

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🌍 BN GAMEEX — PRODUCTION SERVER DEPLOYMENT (PO APPROVED)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Environment pre-flight check
if (-not (Test-Path ".env")) {
    if (Test-Path ".env.example") {
        Write-Host "[DEPLOY] Copying .env from .env.example..." -ForegroundColor Yellow
        Copy-Item ".env.example" ".env"
    } else {
        Write-Error "[DEPLOY:ERROR] .env file is missing."
        exit 1
    }
}

# 2. Build Go Binaries
Write-Host "[DEPLOY:1/4] Compiling Go backend services..." -ForegroundColor Green
go build -ldflags="-w -s" -o bin/api.exe ./services/api/cmd
go build -ldflags="-w -s" -o bin/worker.exe ./services/worker/cmd

# 3. Build Admin Console
Write-Host "[DEPLOY:2/4] Building Admin Console bundle..." -ForegroundColor Green
Push-Location apps/admin
npm run build
Pop-Location

# 4. Build Public Web
Write-Host "[DEPLOY:3/4] Building Public Web bundle..." -ForegroundColor Green
Push-Location apps/web
npm run build
Pop-Location

# 5. Launch Docker Stack if Docker is running
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "[DEPLOY:4/4] Launching Docker container stack..." -ForegroundColor Green
    docker compose -f infrastructure/deploy/docker-compose.prod.yml up -d --build
} else {
    Write-Host "[DEPLOY:4/4] Docker CLI not found. Binaries and web distributions built for manual process runner." -ForegroundColor Yellow
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "✅ BN GAMEEX DEPLOYMENT PACKAGING COMPLETE!" -ForegroundColor Green
Write-Host "==========================================================" -ForegroundColor Cyan

