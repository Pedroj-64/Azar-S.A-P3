#!/usr/bin/env bash
# scripts/server_up.sh
# ─────────────────────────────────────────────────────────────────
# Levanta el servidor central de Azar S.A.
# Uso: ./scripts/server_up.sh [IP_forzada]
# ─────────────────────────────────────────────────────────────────

# Ir siempre a la raíz del proyecto (donde está mix.exs)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/.."

# ── Detectar IP ───────────────────────────────────────────────────
if [ -n "${1:-}" ]; then
  LOCAL_IP="$1"
else
  # Método 1: ip route (Linux moderno, el más fiable)
  LOCAL_IP=$(ip route get 1.1.1.1 2>/dev/null \
    | grep -oP 'src \K[\d.]+' | head -1)

  # Método 2: ip addr (alternativa en Linux)
  if [ -z "$LOCAL_IP" ]; then
    LOCAL_IP=$(ip -4 addr show scope global 2>/dev/null \
      | grep -oP '(?<=inet )[\d.]+' | head -1)
  fi

  # Método 3: macOS
  if [ -z "$LOCAL_IP" ] && command -v ipconfig &>/dev/null; then
    LOCAL_IP=$(ipconfig getifaddr en0 2>/dev/null || true)
  fi
fi

# Validar que sea un IPv4 real
if [[ "$LOCAL_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  NODE_ARG="--name server@${LOCAL_IP}"
  ACCESS_URL="http://${LOCAL_IP}:4000"
else
  NODE_ARG="--sname server"
  LOCAL_IP="localhost"
  ACCESS_URL="http://localhost:4000"
fi

# ── Liberar puerto 4000 si ya está en uso ────────────────────────
if command -v fuser &>/dev/null && fuser 4000/tcp &>/dev/null; then
  echo "  ⚠️  Puerto 4000 ocupado. Liberando proceso anterior..."
  fuser -k 4000/tcp 2>/dev/null
  sleep 1
  echo "  ✅ Puerto 4000 liberado."
elif command -v lsof &>/dev/null && lsof -ti:4000 &>/dev/null; then
  echo "  ⚠️  Puerto 4000 ocupado. Liberando proceso anterior..."
  lsof -ti:4000 | xargs kill -9 2>/dev/null
  sleep 1
  echo "  ✅ Puerto 4000 liberado."
fi

# ── Primer arranque: correr seeds si no hay datos ─────────────────
if [ ! -f "priv/data/admins.json" ]; then
  echo ""
  echo "  ⚙️  Primera ejecución detectada — cargando datos iniciales..."
  mix run priv/seeds.exs
  echo ""
fi

# ── Banner ────────────────────────────────────────────────────────
clear
echo ""
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║           🎰  AZAR S.A. — Servidor Central           ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║                                                      ║"
printf "  ║  🌐 Dirección del servidor : %-24s║\n" "$ACCESS_URL"
echo "  ║                                                      ║"
echo "  ║  📋 Credenciales de acceso:                          ║"
echo "  ║                                                      ║"
echo "  ║   Rol       │ Usuario / Cédula  │ Contraseña         ║"
echo "  ║  ───────────┼───────────────────┼──────────────────  ║"
echo "  ║   Admin     │ admin             │ 1234               ║"
echo "  ║   Jugador   │ 1001234567        │ 1234               ║"
echo "  ║                                                      ║"
echo "  ║  ℹ️  Comparte tu IP con otros jugadores:              ║"
printf "  ║     %-49s║\n" "$LOCAL_IP"
echo "  ║                                                      ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo ""
echo "  Iniciando servidor... (Ctrl+C para detener)"
echo ""

# ── Lanzar Phoenix ────────────────────────────────────────────────
exec iex $NODE_ARG --cookie azar_sa_cookie -S mix phx.server
