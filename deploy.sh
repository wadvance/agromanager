#!/bin/bash
# Script de despliegue para AgroManager
# Uso: ./deploy.sh firebase|netlify|github|vercel

set -e

TARGET="${1:-firebase}"
SKIP_BUILD="${2:-false}"
FLUTTER="${FLUTTER:-flutter}"

echo "========================================"
echo "  AgroManager - Deploy Tool"
echo "========================================"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

# 1. Build
if [ "$SKIP_BUILD" != "true" ]; then
  echo -e "${YELLOW}[1/3] Compilando para web...${NC}"
  $FLUTTER build web --release
  echo -e "${GREEN}  OK: build/web generado${NC}"
else
  echo -e "${YELLOW}[1/3] Usando build existente...${NC}"
fi

# 2. Verificar
if [ ! -f "build/web/index.html" ]; then
  echo -e "${RED}ERROR: No se encuentra build/web/index.html${NC}"
  echo -e "${RED}  Ejecuta: flutter build web --release${NC}"
  exit 1
fi
echo -e "${GREEN}  OK: build verificado${NC}"

# 3. Deploy
echo -e "${YELLOW}[2/3] Desplegando a $TARGET...${NC}"

case $TARGET in
  firebase)
    npx firebase-tools deploy --only hosting
    echo -e "${CYAN}  URL: https://agromanager.web.app${NC}"
    ;;
  netlify)
    echo -e "${CYAN}  Arrastra build/web a https://app.netlify.com/drop${NC}"
    echo -e "${CYAN}  O usa: npx netlify-cli deploy --prod --dir=build/web${NC}"
    ;;
  github)
    echo -e "${CYAN}  Push a GitHub y el Action deploy.yml se encarga${NC}"
    echo -e "${CYAN}  1. git add . && git commit -m 'release' && git push${NC}"
    ;;
  vercel)
    npx vercel --prod build/web
    ;;
esac

echo -e "${GREEN}[3/3] ¡Despliegue completado!${NC}"
echo -e "${CYAN}========================================${NC}"
