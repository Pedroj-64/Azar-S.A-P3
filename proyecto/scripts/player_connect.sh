#!/usr/bin/env bash
# scripts/player_connect.sh
# ─────────────────────────────────────────────────────────────────
# Script para jugadores en OTRO PC.
# Les dice a dónde conectarse y abre el navegador automáticamente.
#
# Uso:
#   ./player_connect.sh 192.168.1.42       ← IP del servidor
#   ./player_connect.sh                     ← te pide la IP
# ─────────────────────────────────────────────────────────────────

clear
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║           🎰  AZAR S.A. — Acceso Jugador             ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

# ── Obtener la IP del servidor ────────────────────────────────────
if [ -n "${1:-}" ]; then
  SERVER_IP="$1"
else
  echo "  ¿Cuál es la IP del servidor? (pídela al admin)"
  echo "  Ejemplo: 192.168.1.42"
  echo ""
  read -rp "  IP del servidor: " SERVER_IP
fi

# Validar formato básico de IP
if ! [[ "$SERVER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && [ "$SERVER_IP" != "localhost" ]; then
  echo ""
  echo "  ❌ IP inválida: '$SERVER_IP'"
  echo "     Asegúrate de ingresar algo como: 192.168.1.42"
  exit 1
fi

SERVER_URL="http://${SERVER_IP}:4000"
PLAYER_URL="${SERVER_URL}/player/login"

# ── Verificar conectividad (opcional, no bloquea) ─────────────────
echo ""
echo "  🔍 Verificando conexión con el servidor..."
if curl -s --max-time 3 "$SERVER_URL" > /dev/null 2>&1; then
  echo "  ✅ Servidor encontrado y respondiendo."
else
  echo "  ⚠️  El servidor no respondió. Verifica que esté encendido."
  echo "     Intentando abrir de todas formas..."
fi

# ── Mostrar información ───────────────────────────────────────────
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║  🌐 Abriendo: $PLAYER_URL"
echo "  ║                                                      ║"
echo "  ║  📋 Tus datos de acceso:                             ║"
echo "  ║   🪪 Cédula     : 1001234567                         ║"
echo "  ║   🔑 Contraseña : 1234                               ║"
echo "  ║                                                      ║"
echo "  ║  Si no tienes cuenta, regístrate en:                 ║"
printf "  ║   %-49s║\n" "${SERVER_URL}/player/register"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""

# ── Abrir navegador ───────────────────────────────────────────────
if command -v xdg-open &>/dev/null; then
  xdg-open "$PLAYER_URL" 2>/dev/null &
elif command -v open &>/dev/null; then
  open "$PLAYER_URL"
elif command -v start &>/dev/null; then
  start "$PLAYER_URL"
else
  echo "  ⚠️  No se pudo abrir el navegador automáticamente."
  echo "     Copia y pega este enlace en tu navegador:"
  echo "     $PLAYER_URL"
fi

echo "  ✅ Listo. Abre tu navegador en: $PLAYER_URL"
echo ""
