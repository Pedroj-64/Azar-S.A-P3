defmodule AzarSa.Core.Servers.DrawRestorer do
  @moduledoc """
  Tarea de arranque que restaura los procesos DrawServer desde los
  archivos JSON persistidos en disco.

  Problema que resuelve:
  Los seeds (o sesiones anteriores) crean sorteos que se guardan como JSON,
  pero al reiniciar la aplicación esos procesos GenServer no existen.
  La UI los muestra (lee JSON) pero toda operación falla con :draw_not_found
  porque no hay proceso vivo en el Registry.

  Este módulo se ejecuta una sola vez al arrancar, después del DrawSupervisor,
  y levanta un DrawServer por cada JSON encontrado.
  """
  use Task, restart: :temporary

  alias AzarSa.Core.Data.Store
  alias AzarSa.Core.Servers.DrawSupervisor

  require Logger

  def start_link(_args) do
    Task.start_link(__MODULE__, :run, [])
  end

  def run do
    draws = Store.list_draws()

    if draws != [] do
      Logger.info("[DrawRestorer] Restaurando #{length(draws)} sorteo(s) desde disco...")

      results =
        Enum.map(draws, fn draw ->
          draw_id       = draw["id"]
          name          = draw["name"] || draw_id
          date          = draw["date"]
          ticket_price  = draw["ticket_price"] || 0
          fractions     = draw["fractions"] || 1
          total_tickets = draw["total_tickets"] || 1000

          case DrawSupervisor.start_draw(draw_id, name, date, ticket_price, fractions, total_tickets) do
            {:ok, _pid} ->
              Logger.info("[DrawRestorer] #{name} (#{draw_id})")
              :ok

            {:error, {:already_started, _pid}} ->
              Logger.info("[DrawRestorer] #{draw_id} ya estaba vivo")
              :ok

            error ->
              Logger.warning("[DrawRestorer] #{draw_id}: #{inspect(error)}")
              :error
          end
        end)

      ok_count = Enum.count(results, &(&1 == :ok))
      Logger.info("[DrawRestorer] #{ok_count}/#{length(draws)} sorteos restaurados correctamente.")
    end
  end
end
