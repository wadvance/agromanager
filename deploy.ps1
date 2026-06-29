<#
.SYNOPSIS
  Script de despliegue para AgroManager
.DESCRIPTION
  Compila y despliega la app web a Firebase Hosting, Netlify o GitHub Pages
.PARAMETER Target
  Plataforma de destino: firebase, netlify, github, vercel
.PARAMETER SkipBuild
  Omite el build y usa el existente en build/web/
.EXAMPLE
  .\deploy.ps1 -Target firebase
  .\deploy.ps1 -Target netlify -SkipBuild
#>

param(
  [ValidateSet('firebase', 'netlify', 'github', 'vercel')]
  [string]$Target = 'firebase',
  [switch]$SkipBuild
)

$ErrorActionPreference = 'Stop'
$flutter = "C:\flutter-sdk\bin\flutter.bat"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AgroManager - Deploy Tool" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Build
if (-not $SkipBuild) {
  Write-Host "[1/3] Compilando para web..." -ForegroundColor Yellow
  & $flutter build web --release
  if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Falló la compilación" -ForegroundColor Red
    exit 1
  }
  Write-Host "  OK: build/web generado" -ForegroundColor Green
} else {
  Write-Host "[1/3] Usando build existente..." -ForegroundColor Yellow
}

# 2. Verificar build
if (-not (Test-Path "build/web/index.html")) {
  Write-Host "ERROR: No se encuentra build/web/index.html" -ForegroundColor Red
  Write-Host "  Ejecuta: flutter build web --release" -ForegroundColor Red
  exit 1
}
Write-Host "  OK: build verificado" -ForegroundColor Green

# 3. Deploy
Write-Host "[2/3] Desplegando a $Target..." -ForegroundColor Yellow

switch ($Target) {
  'firebase' {
    if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
      Write-Host "  Instalando Firebase CLI..." -ForegroundColor Yellow
      npm install -g firebase-tools
    }
    Write-Host "  Ejecutando: firebase deploy --only hosting" -ForegroundColor Gray
    Write-Host "  (Necesitas haber hecho: firebase login primero)" -ForegroundColor Gray
    firebase deploy --only hosting
  }
  'netlify' {
    if (Get-Command npx -ErrorAction SilentlyContinue) {
      Write-Host "  Ejecutando: npx netlify-cli deploy --prod --dir=build/web" -ForegroundColor Gray
      Write-Host "  (Necesitas haber hecho: npx netlify-cli login primero)" -ForegroundColor Gray
      npx netlify-cli deploy --prod --dir=build/web
    } else {
      Write-Host "  Arrastra la carpeta build/web a https://app.netlify.com/drop" -ForegroundColor Cyan
    }
  }
  'github' {
    Write-Host "  Sube el repo a GitHub y activa GitHub Pages:" -ForegroundColor Cyan
    Write-Host "  1. git add ." -ForegroundColor Gray
    Write-Host "  2. git commit -m 'release'" -ForegroundColor Gray
    Write-Host "  3. git push origin main" -ForegroundColor Gray
    Write-Host "  4. GitHub Actions buildeará y desplegará automáticamente" -ForegroundColor Gray
    Write-Host "  (El workflow está en .github/workflows/deploy.yml)" -ForegroundColor Gray
  }
  'vercel' {
    if (Get-Command vercel -ErrorAction SilentlyContinue) {
      Write-Host "  Ejecutando: vercel --prod build/web" -ForegroundColor Gray
      vercel --prod build/web
    } else {
      Write-Host "  Instala Vercel CLI: npm i -g vercel" -ForegroundColor Yellow
      Write-Host "  Luego: vercel --prod build/web" -ForegroundColor Gray
    }
  }
}

Write-Host ""
Write-Host "[3/3] ¡Despliegue completado!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
