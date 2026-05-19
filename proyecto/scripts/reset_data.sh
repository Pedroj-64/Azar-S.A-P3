#!/usr/bin/env bash
# scripts/reset_data.sh
# ─────────────────────────────────────────────────────────────────
# Resetea todos los datos del sistema a su estado inicial de prueba.
# Elimina sorteos, limpia clientes y deja datos demo listos.
# Uso: ./scripts/reset_data.sh
# ─────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
DATA_DIR="$PROJECT_ROOT/priv/data"
DRAWS_DIR="$DATA_DIR/draws"
LOGS_DIR="$PROJECT_ROOT/priv/logs"
UPLOADS_DIR="$PROJECT_ROOT/priv/static/images/uploads"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║       AZAR S.A. — Reset de Datos del Sistema     ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""

# ── Confirmación ──
read -p "  Esto eliminará TODOS los datos actuales. ¿Continuar? (s/N): " confirm
if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
  echo "❌ Cancelado."
  exit 0
fi

echo ""
echo "  Limpiando datos..."

# ── 1. Eliminar todos los sorteos ──
rm -rf "$DRAWS_DIR"
mkdir -p "$DRAWS_DIR"
echo "   ✓ Sorteos eliminados"

# ── 2. Limpiar uploads de imágenes ──
rm -rf "$UPLOADS_DIR"
mkdir -p "$UPLOADS_DIR"
echo "   ✓ Imágenes subidas eliminadas"

# ── 3. Limpiar bitácora ──
> "$LOGS_DIR/bitacora.txt"
echo "   ✓ Bitácora limpia"

# ── 4. Resetear fecha del sistema ──
TODAY=$(date +%Y-%m-%d)
cat > "$DATA_DIR/system_date.json" << EOF
{
  "date": "$TODAY"
}
EOF
echo "   ✓ Fecha del sistema: $TODAY"

# ── 5. Crear admin por defecto (password: 1234) ──
cat > "$DATA_DIR/admins.json" << 'EOF'
[
  {
    "id": "admin_001",
    "username": "admin",
    "password_hash": "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4",
    "created_at": "2026-01-01 00:00:00.000000Z"
  }
]
EOF
echo "   ✓ Admin creado (usuario: admin, contraseña: 1234)"

# ── 6. Crear clientes de prueba ──
# Contraseñas: Carlos=1234, Ana=abcdef, Luis=qwerty, María=123456
cat > "$DATA_DIR/clients.json" << 'EOF'
[
  {
    "id": "client_CARLOS01",
    "name": "Carlos Pérez",
    "document": "1001234567",
    "password_hash": "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4",
    "credit_card": "4111111111111111",
    "balance": 500000,
    "notifications": [],
    "created_at": "2026-01-01 00:00:00.000000Z"
  },
  {
    "id": "client_ANA002",
    "name": "Ana Gómez",
    "document": "1009876543",
    "password_hash": "bef57ec7f53a6d40beb640a780a639c83bc29ac8a9816f1fc6c5c6dcd93c4721",
    "credit_card": "4222222222222222",
    "balance": 500000,
    "notifications": [],
    "created_at": "2026-01-02 00:00:00.000000Z"
  },
  {
    "id": "client_LUIS003",
    "name": "Luis Martínez",
    "document": "1005551234",
    "password_hash": "65e84be33532fb784c48129675f9eff3a682b27168c0ea744b2cf58ee02337c5",
    "credit_card": "4333333333333333",
    "balance": 500000,
    "notifications": [],
    "created_at": "2026-01-03 00:00:00.000000Z"
  },
  {
    "id": "client_MARIA04",
    "name": "María Rodríguez",
    "document": "1007778888",
    "password_hash": "8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92",
    "credit_card": "4444444444444444",
    "balance": 500000,
    "notifications": [],
    "created_at": "2026-01-04 00:00:00.000000Z"
  }
]
EOF
echo "   ✓ 4 clientes de prueba creados"

# ── 7. Crear sorteos de prueba ──
# Fecha: hoy + 7 días para que estén pendientes
FUTURE_DATE=$(date -d "+7 days" +%Y-%m-%d 2>/dev/null || date -v+7d +%Y-%m-%d 2>/dev/null || echo "2026-06-01")
FUTURE_DATE2=$(date -d "+14 days" +%Y-%m-%d 2>/dev/null || date -v+14d +%Y-%m-%d 2>/dev/null || echo "2026-06-08")
FUTURE_DATE3=$(date -d "+3 days" +%Y-%m-%d 2>/dev/null || date -v+3d +%Y-%m-%d 2>/dev/null || echo "2026-05-28")

cat > "$DRAWS_DIR/sorteo_navidad.json" << EOF
{
  "id": "sorteo_navidad",
  "name": "Gran Sorteo de Navidad",
  "date": "$FUTURE_DATE",
  "status": "pending",
  "ticket_price": 50000,
  "fractions": 4,
  "total_tickets": 100,
  "tickets": {},
  "prizes": [
    {
      "id": "prize_nav_01",
      "name": "Gran Premio Navideño",
      "amount": 50000000,
      "created_at": "2026-01-01 00:00:00.000000Z"
    },
    {
      "id": "prize_nav_02",
      "name": "Segundo Premio",
      "amount": 10000000,
      "created_at": "2026-01-01 00:00:01.000000Z"
    },
    {
      "id": "prize_nav_03",
      "name": "Tercer Premio",
      "amount": 5000000,
      "created_at": "2026-01-01 00:00:02.000000Z"
    }
  ],
  "winning_numbers": [],
  "result": null,
  "image": null,
  "created_at": "2026-01-01 00:00:00.000000Z"
}
EOF

cat > "$DRAWS_DIR/sorteo_express.json" << EOF
{
  "id": "sorteo_express",
  "name": "Sorteo Express",
  "date": "$FUTURE_DATE3",
  "status": "pending",
  "ticket_price": 10000,
  "fractions": 2,
  "total_tickets": 50,
  "tickets": {
    "7_full": {
      "number": "7",
      "fraction": "full",
      "client_id": "client_CARLOS01",
      "bought_at": "2026-01-05 10:00:00.000000Z"
    },
    "13_full": {
      "number": "13",
      "fraction": "full",
      "client_id": "client_ANA002",
      "bought_at": "2026-01-05 11:00:00.000000Z"
    },
    "25_1": {
      "number": "25",
      "fraction": "1",
      "client_id": "client_LUIS003",
      "bought_at": "2026-01-05 12:00:00.000000Z"
    }
  },
  "prizes": [
    {
      "id": "prize_exp_01",
      "name": "Premio Único",
      "amount": 1000000,
      "created_at": "2026-01-01 00:00:00.000000Z"
    }
  ],
  "winning_numbers": [],
  "result": null,
  "image": null,
  "created_at": "2026-01-02 00:00:00.000000Z"
}
EOF

cat > "$DRAWS_DIR/sorteo_mayo.json" << EOF
{
  "id": "sorteo_mayo",
  "name": "Sorteo Especial Mayo",
  "date": "$FUTURE_DATE2",
  "status": "pending",
  "ticket_price": 25000,
  "fractions": 3,
  "total_tickets": 150,
  "tickets": {},
  "prizes": [
    {
      "id": "prize_may_01",
      "name": "Gran Premio Mayo",
      "amount": 20000000,
      "created_at": "2026-01-01 00:00:00.000000Z"
    },
    {
      "id": "prize_may_02",
      "name": "Premio Secundario",
      "amount": 5000000,
      "created_at": "2026-01-01 00:00:01.000000Z"
    }
  ],
  "winning_numbers": [],
  "result": null,
  "image": null,
  "created_at": "2026-01-03 00:00:00.000000Z"
}
EOF

echo "   ✓ 3 sorteos de prueba creados"

echo ""
echo "╔══════════════════════════════════════════════════╗"
echo "║              ✅ Reset completado                  ║"
echo "╠══════════════════════════════════════════════════╣"
echo "║                                                  ║"
echo "║  Admin:    admin / 1234                          ║"
echo "║                                                  ║"
echo "║  Jugadores:                                      ║"
echo "║    Carlos Pérez   → 1001234567 / 1234            ║"
echo "║    Ana Gómez      → 1009876543 / abcdef          ║"
echo "║    Luis Martínez  → 1005551234 / qwerty          ║"
echo "║    María Rodríguez→ 1007778888 / 123456          ║"
echo "║                                                  ║"
echo "║  Sorteos: 3 pendientes (con premios)             ║"
echo "║    - Gran Sorteo de Navidad ($FUTURE_DATE)       ║"
echo "║    - Sorteo Express ($FUTURE_DATE3) [3 tickets]  ║"
echo "║    - Sorteo Especial Mayo ($FUTURE_DATE2)        ║"
echo "║                                                  ║"
echo "║  Balance inicial: \$500.000 por jugador           ║"
echo "║                                                  ║"
echo "║   Reinicia el servidor para aplicar cambios    ║"
echo "╚══════════════════════════════════════════════════╝"
echo ""
