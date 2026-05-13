defmodule AzarSa.Core.Services.DrawService do
  @moduledoc """
  Servicio de consultas sobre sorteos.

  Agrupa la lógica de lectura que opera directamente sobre los archivos JSON
  persistidos, evitando que el CentralServer consulte la capa de datos directamente.
  No escribe datos; solo lee y transforma.
  """

  alias AzarSa.Core.Data.Store

  @doc "Lista todos los sorteos ordenados por fecha (ascendente)."
  def list_draws_sorted do
    # OPTIMIZACIÓN: Leer archivos en paralelo usando todos los núcleos del CPU
    # Esto es mucho más rápido si hay cientos de archivos JSON.
    path = Path.join("priv/data/draws", "*.json")

    Path.wildcard(path)
    |> Task.async_stream(fn file ->
      {:ok, content} = File.read(file)
      Jason.decode!(content)
    end)
    |> Enum.map(fn {:ok, draw} -> draw end)
    |> Enum.sort_by(fn draw -> draw["date"] || "" end)
  end

  @doc "Lista solo sorteos en estado :pending (aún no ejecutados)."
  def list_pending_draws do
    list_draws_sorted()
    |> Enum.filter(fn draw -> draw["status"] == "pending" end)
  end

  @doc "Lista solo sorteos ejecutados (:done)."
  def list_finished_draws do
    list_draws_sorted()
    |> Enum.filter(fn draw -> draw["status"] == "done" end)
  end

  @doc """
  Retorna el balance de todos los sorteos pasados.
  Por cada sorteo: {draw_id, name, revenue, total_prizes, profit}.
  Al final incluye el resumen total acumulado.
  """
  def get_draws_balance do
    finished = list_finished_draws()

    draw_balances =
      Enum.map(finished, fn draw ->
        revenue = calculate_revenue(draw)
        total_prizes = calculate_total_prizes(draw)
        profit = revenue - total_prizes

        %{
          draw_id: draw["id"],
          name: draw["name"],
          date: draw["date"],
          revenue: revenue,
          total_prizes: total_prizes,
          profit: profit
        }
      end)

    total_revenue = Enum.sum(Enum.map(draw_balances, & &1.revenue))
    total_prizes = Enum.sum(Enum.map(draw_balances, & &1.total_prizes))

    %{
      draws: draw_balances,
      summary: %{
        total_revenue: total_revenue,
        total_prizes: total_prizes,
        total_profit: total_revenue - total_prizes
      }
    }
  end

  @doc """
  Retorna todos los premios entregados en sorteos ejecutados.
  Incluye: nombre del premio, ganador (nombre resuelto), monto, sorteo,
  dinero recolectado, y ganancia/pérdida por sorteo.
  """
  def get_delivered_prizes do
    clients_map = build_clients_map()

    list_finished_draws()
    |> Enum.flat_map(fn draw ->
      result = draw["result"] || %{}
      prize_winners = result["prize_winners"] || []
      draw_name = draw["name"] || draw["id"]
      fractions = max(draw["fractions"] || 1, 1)
      revenue = calculate_revenue(draw)

      if prize_winners != [] do
        # Nuevo formato: un ganador por premio
        Enum.map(prize_winners, fn pw ->
          client_id = pw["winner_client_id"]
          prize_per_fraction = div(pw["prize_amount"] || 0, fractions)

          %{
            draw_id: draw["id"],
            draw_name: draw_name,
            prize_name: pw["prize_name"] || "",
            amount: pw["prize_amount"] || 0,
            amount_per_fraction: prize_per_fraction,
            winner_client_id: client_id,
            winner_name: Map.get(clients_map, client_id, client_id || "—"),
            winner_number: pw["winner_number"],
            winner_fraction: pw["winner_fraction"],
            drawn_at: result["drawn_at"],
            revenue: revenue
          }
        end)
      else
        # Fallback: formato antiguo (un solo ganador)
        winner_client = result["winner_client_id"]

        (draw["prizes"] || [])
        |> Enum.map(fn prize ->
          prize_amount = prize["amount"] || Map.get(prize, "amount", 0)
          prize_per_fraction = div(prize_amount, fractions)

          %{
            draw_id: draw["id"],
            draw_name: draw_name,
            prize_name: prize["name"] || Map.get(prize, "name", ""),
            amount: prize_amount,
            amount_per_fraction: prize_per_fraction,
            winner_client_id: winner_client,
            winner_name: Map.get(clients_map, winner_client, winner_client || "—"),
            winner_number: result["winner_number"],
            winner_fraction: nil,
            drawn_at: result["drawn_at"],
            revenue: revenue
          }
        end)
      end
    end)
  end

  @doc "Retorna todos los premios ganados por un cliente específico."
  def get_prizes_won_by(client_id) do
    prizes =
      list_finished_draws()
      |> Enum.flat_map(fn draw ->
        result = draw["result"] || %{}
        prize_winners = result["prize_winners"] || []
        draw_name = draw["name"] || draw["id"]

        if prize_winners != [] do
          # Nuevo formato
          prize_winners
          |> Enum.filter(fn pw -> pw["winner_client_id"] == client_id end)
          |> Enum.map(fn pw ->
            %{
              draw_id: draw["id"],
              draw_name: draw_name,
              prize_name: pw["prize_name"] || "",
              amount: pw["prize_amount"] || 0,
              winner_number: pw["winner_number"],
              drawn_at: result["drawn_at"]
            }
          end)
        else
          # Fallback antiguo
          if result["winner_client_id"] == client_id do
            (draw["prizes"] || [])
            |> Enum.map(fn prize ->
              %{
                draw_id: draw["id"],
                draw_name: draw_name,
                prize_name: prize["name"] || "",
                amount: prize["amount"] || 0,
                winner_number: result["winner_number"],
                drawn_at: result["drawn_at"]
              }
            end)
          else
            []
          end
        end
      end)

    {:ok, prizes}
  end

  @doc """
  Resuelve el nombre de un cliente dado su ID.
  """
  def resolve_client_name(client_id) do
    clients_map = build_clients_map()
    Map.get(clients_map, client_id, client_id || "—")
  end

  @doc """
  Resuelve una lista de client_ids a sus nombres.
  Retorna una lista de {client_id, client_name}.
  """
  def resolve_client_names(client_ids) do
    clients_map = build_clients_map()

    Enum.map(client_ids, fn id ->
      {id, Map.get(clients_map, id, id || "—")}
    end)
  end

  ## Helpers privados

  defp build_clients_map do
    Store.read("clients.json")
    |> Enum.reduce(%{}, fn client, acc ->
      Map.put(acc, client["id"], client["name"] || client["document"] || "—")
    end)
  end

  defp calculate_revenue(draw) do
    ticket_price = draw["ticket_price"] || 0
    fractions = max(draw["fractions"] || 1, 1)
    fraction_price = div(ticket_price, fractions)
    tickets_sold = map_size(draw["tickets"] || %{})
    tickets_sold * fraction_price
  end

  defp calculate_total_prizes(draw) do
    (draw["prizes"] || [])
    |> Enum.reduce(0, fn p, acc ->
      acc + (p["amount"] || Map.get(p, :amount, 0))
    end)
  end
end
