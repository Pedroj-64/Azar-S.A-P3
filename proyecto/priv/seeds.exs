#!/usr/bin/env elixir
# priv/seeds.exs
# ─────────────────────────────────────────────────────────────────
# Datos de prueba para Azar S.A.
# Ejecutar con:  mix run priv/seeds.exs
#
# Credenciales de prueba:
#   Admin  → usuario: admin       contraseña: 1234
#   Player → cédula : 1001234567  contraseña: 1234
# ─────────────────────────────────────────────────────────────────

alias AzarSa.Core.Servers.CentralServer

IO.puts("""
============================================================
  🎰  AZAR S.A. — Cargando datos de prueba
============================================================
""")

# ── Administrador ─────────────────────────────────────────────────
IO.puts("► Creando administrador...")

case AzarSa.Core.Services.AdminService.create_admin("admin", "1234") do
  {:ok, admin} ->
    IO.puts("  ✅ Admin creado: #{admin["username"]} / 1234")

  {:error, :admin_exists} ->
    IO.puts("  ⚠️  Admin 'admin' ya existe (contraseña: 1234)")
end

:timer.sleep(100)

# ── Clientes / Jugadores ──────────────────────────────────────────
IO.puts("\n► Registrando jugadores...")

clients = [
  # {nombre,           cédula,        contraseña, tarjeta}
  {"Carlos Pérez",     "1001234567",  "1234",     "4111111111111111"},
  {"Ana Gómez",        "1009876543",  "pass456",  "4222222222222222"},
  {"Luis Martínez",    "1005551234",  "pass789",  "4333333333333333"},
  {"María Rodríguez",  "1007778888",  "pass2024", "4444444444444444"}
]

registered_clients =
  Enum.map(clients, fn {name, doc, pass, card} ->
    case CentralServer.register_client(name, doc, pass, card) do
      {:ok, client} ->
        IO.puts("  ✅ #{name}  |  cédula: #{doc}  |  pass: #{pass}")
        client

      {:error, :document_exists} ->
        IO.puts("  ⚠️  Ya existe: #{doc}")
        # Buscar el cliente en la store para seguir usando su ID
        clients_in_store = AzarSa.Core.Data.Store.read("clients.json")
        Enum.find(clients_in_store, fn c -> c["document"] == doc end)
    end
  end)
  |> Enum.reject(&is_nil/1)

:timer.sleep(100)

# ── Sorteos ───────────────────────────────────────────────────────
IO.puts("\n► Creando sorteos...")

draws = [
  %{
    id: "sorteo_default",
    name: "Gran Sorteo Mayo 2026",
    date: "2026-05-31",
    ticket_price: 50_000,
    fractions: 10,
    total_tickets: 100
  },
  %{
    id: "sorteo_junio_2026",
    name: "Sorteo Especial Junio 2026",
    date: "2026-06-15",
    ticket_price: 100_000,
    fractions: 5,
    total_tickets: 50
  },
  %{
    id: "sorteo_pasado",
    name: "Sorteo Histórico Abril 2026",
    date: "2026-04-30",
    ticket_price: 30_000,
    fractions: 3,
    total_tickets: 200
  }
]

Enum.each(draws, fn draw ->
  case CentralServer.create_draw(
         draw.id,
         draw.name,
         draw.date,
         draw.ticket_price,
         draw.fractions,
         draw.total_tickets
       ) do
    {:ok, id} ->
      IO.puts("  ✅ #{draw.name}  (id: #{id})")

    {:error, :draw_already_exists} ->
      IO.puts("  ⚠️  Ya existe: #{draw.id}")
  end
end)

:timer.sleep(100)

# ── Premios ───────────────────────────────────────────────────────
IO.puts("\n► Agregando premios...")

prizes = [
  {"sorteo_default",   "Premio Mayor",    30_000_000},
  {"sorteo_default",   "Segundo Premio",  10_000_000},
  {"sorteo_default",   "Tercer Premio",    5_000_000},
  {"sorteo_junio_2026","Premio Único",    50_000_000},
  {"sorteo_pasado",    "Gran Premio",     25_000_000}
]

Enum.each(prizes, fn {draw_id, name, amount} ->
  case CentralServer.add_prize(draw_id, name, amount) do
    {:ok, _} ->
      IO.puts("  ✅ #{name}  →  #{draw_id}  ($#{amount |> Integer.to_string() |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()})")

    {:error, reason} ->
      IO.puts("  ⚠️  Error en #{name}: #{reason}")
  end
end)

:timer.sleep(100)

# ── Comprar tickets para el jugador principal (Carlos / 1234) ─────
IO.puts("\n► Comprando tickets para Carlos Pérez...")

first_client = Enum.find(registered_clients, fn c ->
  c["document"] == "1001234567"
end)

if first_client do
  client_id = first_client["id"]
  tickets = [{0, :full}, {1, 1}, {2, 2}, {5, :full}, {10, :full}]

  Enum.each(tickets, fn {number, fraction} ->
    case CentralServer.buy_ticket("sorteo_default", client_id, number, fraction) do
      {:ok, result} ->
        IO.puts("  ✅ Ticket ##{result.number} (fracción: #{inspect(result.fraction)})")

      {:error, reason} ->
        IO.puts("  ⚠️  Ticket ##{number}: #{reason}")
    end
  end)
else
  IO.puts("  ⚠️  No se encontró a Carlos, saltando compra de tickets")
end

:timer.sleep(100)

# ── Ejecutar el sorteo histórico ──────────────────────────────────
IO.puts("\n► Ejecutando sorteo histórico...")

case CentralServer.run_draw("sorteo_pasado") do
  {:ok, result} ->
    IO.puts("  ✅ Sorteo histórico ejecutado. Número ganador: #{result["winner_number"]}")

  {:error, reason} ->
    IO.puts("  ⚠️  No se pudo ejecutar: #{reason}")
end

IO.puts("""

============================================================
  ✅ Datos cargados correctamente.

  Credenciales para ingresar:
  ┌─────────────┬──────────────┬──────────┐
  │  Rol        │  Usuario     │  Clave   │
  ├─────────────┼──────────────┼──────────┤
  │  Admin      │  admin       │  1234    │
  │  Jugador    │  1001234567  │  1234    │
  └─────────────┴──────────────┴──────────┘

  http://localhost:4000
============================================================
""")
