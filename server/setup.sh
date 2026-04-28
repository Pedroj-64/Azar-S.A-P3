#!/bin/bash
# setup.sh - Prepara el servidor para desarrollo

echo "🚀 Setup del Servidor Azar"

# Copiar assets desde assets/ a priv/static/
echo "📦 Copiando assets..."
mkdir -p priv/static/css priv/static/js priv/static/locales priv/static/images

# Copiar CSS
if [ -f "assets/css/app.css" ]; then
  cp -v assets/css/app.css priv/static/css/
else
  echo "⚠️ No encontrado: assets/css/app.css"
fi

# Copiar JS
if [ -f "assets/js/i18n-theme.js" ]; then
  cp -v assets/js/i18n-theme.js priv/static/js/
else
  echo "⚠️ No encontrado: assets/js/i18n-theme.js"
fi

# Copiar locales
if [ -d "assets/locales" ] && [ "$(ls -A assets/locales/*.json 2>/dev/null)" ]; then
  cp -v assets/locales/*.json priv/static/locales/
else
  echo "⚠️ No encontrados: assets/locales/*.json"
fi

echo "✓ Assets preparados"
echo ""
echo "Próximos pasos:"
echo "  1. mix setup          # Descarga dependencias"
echo "  2. mix phx.server     # Inicia el servidor"
echo ""
echo "IMPORTANTE:"
echo "  - Edita archivos en: assets/ (CSS, JS, locales)"
echo "  - NO edites en priv/static/ (se sobrescriben en setup)"
echo ""
