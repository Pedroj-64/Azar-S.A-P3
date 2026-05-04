defmodule AzarSa.Core.Services.DrawService do
  @moduledoc """
  Servicio de consultas sobre sorteos.

  Agrupa la lógica de lectura que opera directamente sobre los archivos JSON
  persistidos, evitando que el CentralServer consulte la capa de datos directamente.
  No escribe datos; solo lee y transforma.
  """

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
  Incluye: nombre del premio, ganador, monto, nombre del sorteo.
  """
  def get_delivered_prizes do
    list_finished_draws()
    |> Enum.flat_map(fn draw ->
      result = draw["result"] || %{}
      winner_client = result["winner_client_id"]
      draw_name = draw["name"] || draw["id"]

      (draw["prizes"] || [])
      |> Enum.map(fn prize ->
        %{
          draw_id: draw["id"],
          draw_name: draw_name,
          prize_name: prize["name"] || Map.get(prize, "name", ""),
          amount: prize["amount"] || Map.get(prize, "amount", 0),
          winner_client_id: winner_client,
          drawn_at: result["drawn_at"]
        }
      end)
    end)
  end

  @doc "Retorna todos los premios ganados por un cliente específico."
  def get_prizes_won_by(client_id) do
    prizes =
      list_finished_draws()
      |> Enum.filter(fn draw ->
        result = draw["result"] || %{}
        result["winner_client_id"] == client_id
      end)
      |> Enum.flat_map(fn draw ->
        result = draw["result"] || %{}
        draw_name = draw["name"] || draw["id"]

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
      end)

    {:ok, prizes}
  end

  ## Helpers privados

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
