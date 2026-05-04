#!/usr/bin/env elixir
# priv/seeds.exs
# ─────────────────────────────────────────────────────────────────
# Datos de prueba para Azar S.A.
# Ejecutar con: mix run priv/seeds.exs
# Crea clientes, sorteos, premios y compras de tickets de ejemplo.
# ─────────────────────────────────────────────────────────────────

alias AzarSa.Core.Servers.CentralServer

IO.puts("Iniciando carga de datos de prueba...")

# ── Administradores ───────────────────────────────────────────────────
IO.puts("Creando administrador por defecto...")

case AzarSa.Core.Services.AdminService.create_admin("admin", "admin123") do
  {:ok, admin} ->
    IO.puts("  ✅ Administrador creado: #{admin["username"]}")

  {:error, :admin_exists} ->
    IO.puts("  ⚠️  Administrador 'admin' ya existe.")
end

:timer.sleep(200)

# ── Clientes ──────────────────────────────────────────────────────
clients = [
  {"Carlos Pérez",     "1001234567", "password123", "4111111111111111"},
  {"Ana Gómez",        "1009876543", "password456", "4222222222222222"},
  {"Luis Martínez",    "1005551234", "password789", "4333333333333333"},
  {"María Rodríguez",  "1007778888", "pass2024",    "4444444444444444"}
]

registered_clients =
  Enum.map(clients, fn {name, doc, pass, card} ->
    case CentralServer.register_client(name, doc, pass, card) do
      {:ok, client} ->
        IO.puts("  ✅ Cliente registrado: #{name} (#{doc})")
        client

      {:error, :document_exists} ->
        IO.puts("  ⚠️  Cliente ya existe: #{doc}")
        nil
    end
  end)
  |> Enum.reject(&is_nil/1)

:timer.sleep(200)

# ── Sorteos ───────────────────────────────────────────────────────
draws = [
  %{
    id: "sorteo_mayo_2026",
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
      IO.puts("  ✅ Sorteo creado: #{draw.name} (#{id})")

    {:error, :draw_already_exists} ->
      IO.puts("  ⚠️  Sorteo ya existe: #{draw.id}")
  end
end)

:timer.sleep(200)

# ── Premios ───────────────────────────────────────────────────────
prizes = [
  {"sorteo_mayo_2026",   "Premio Mayor",     30_000_000},
  {"sorteo_mayo_2026",   "Segundo Premio",   10_000_000},
  {"sorteo_junio_2026",  "Premio Único",     50_000_000},
  {"sorteo_pasado",      "Gran Premio",      25_000_000}
]

Enum.each(prizes, fn {draw_id, name, amount} ->
  case CentralServer.add_prize(draw_id, name, amount) do
    {:ok, _} ->
      IO.puts("  ✅ Premio creado: #{name} → #{draw_id}")

    {:error, reason} ->
      IO.puts("  ⚠️  Error en premio #{name}: #{reason}")
  end
end)

:timer.sleep(200)

# ── Compra de tickets (sorteo de prueba) ──────────────────────────
if length(registered_clients) > 0 do
  first_client = hd(registered_clients)
  client_id = first_client.id

  tickets = [{0, :full}, {1, 1}, {1, 2}, {5, :full}, {10, :full}]

  Enum.each(tickets, fn {number, fraction} ->
    case CentralServer.buy_ticket("sorteo_mayo_2026", client_id, number, fraction) do
      {:ok, result} ->
        IO.puts("  ✅ Ticket comprado: número #{result.number} (#{inspect(result.fraction)})")

      {:error, reason} ->
        IO.puts("  ⚠️  Error comprando ticket #{number}: #{reason}")
    end
  end)
end

:timer.sleep(200)

# ── Ejecutar sorteo histórico ─────────────────────────────────────
case CentralServer.run_draw("sorteo_pasado") do
  {:ok, result} ->
    IO.puts("  ✅ Sorteo histórico ejecutado: ganador #{result["winner_number"]}")

  {:error, reason} ->
    IO.puts("  ⚠️  No se pudo ejecutar sorteo histórico: #{reason}")
end

IO.puts("\n✅ Datos de prueba cargados correctamente.")
