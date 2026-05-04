defmodule AzarSa.Core.Support.SystemDate do
  @moduledoc """
  Servidor que gestiona la fecha del sistema.

  Permite al administrador avanzar la fecha, lo que dispara automáticamente
  la ejecución de todos los sorteos pendientes cuya fecha sea menor o igual
  a la nueva fecha del sistema.

  La fecha se guarda en priv/data/system_date.json para persistencia entre reinicios.
  """

  use GenServer

  alias AzarSa.Core.Data.Store
  alias AzarSa.Core.Servers.CentralServer
  alias AzarSa.Core.Support.AuditLogger

  @state_file "system_date.json"

  ## API pública

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc "Retorna la fecha actual del sistema como string ISO 8601."
  def get_date do
    GenServer.call(__MODULE__, :get_date)
  end

  @doc """
  Avanza la fecha del sistema a `new_date` (string \"YYYY-MM-DD\").
  Ejecuta automáticamente todos los sorteos pendientes hasta esa fecha.
  Retorna {:ok, executed_draws} o {:error, :invalid_date}.
  """
  def advance_date(new_date) do
    GenServer.call(__MODULE__, {:advance_date, new_date})
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    date =
      case Store.read(@state_file) do
        # Sin datos previos: usar fecha de hoy
        [] -> Date.utc_today() |> Date.to_string()
        %{"date" => d} -> d
        # Fallback por si el JSON tiene formato inesperado
        _ -> Date.utc_today() |> Date.to_string()
      end

    {:ok, %{current_date: date}}
  end

  @impl true
  def handle_call(:get_date, _from, state) do
    {:reply, state.current_date, state}
  end

  @impl true
  def handle_call({:advance_date, new_date}, _from, state) do
    case Date.from_iso8601(new_date) do
      {:error, _} ->
        {:reply, {:error, :invalid_date}, state}

      {:ok, target_date} ->
        current = Date.from_iso8601!(state.current_date)

        if Date.compare(target_date, current) == :lt do
          {:reply, {:error, :date_in_the_past}, state}
        else
          # Ejecutar sorteos pendientes hasta la nueva fecha
          executed = run_pending_draws(new_date)

          new_state = %{state | current_date: new_date}
          Store.write(@state_file, %{"date" => new_date})

          AuditLogger.log_ok("advance_date", "nueva fecha: #{new_date}, sorteos ejecutados: #{length(executed)}")

          {:reply, {:ok, executed}, new_state}
        end
    end
  end

  ## Helpers privados

  # Obtiene todos los sorteos en estado :pending cuya fecha <= new_date y los ejecuta.
  defp run_pending_draws(up_to_date_str) do
    {:ok, up_to_date} = Date.from_iso8601(up_to_date_str)

    draws = AzarSa.Core.Data.Store.list_draws()

    draws
    |> Enum.filter(fn draw ->
      draw["status"] == "pending" and draw_date_due?(draw["date"], up_to_date)
    end)
    |> Enum.map(fn draw ->
      draw_id = draw["id"]
      result = CentralServer.run_draw(draw_id)
      {draw_id, result}
    end)
  end

  defp draw_date_due?(nil, _), do: false

  defp draw_date_due?(date_str, up_to_date) do
    case Date.from_iso8601(date_str) do
      {:ok, draw_date} -> Date.compare(draw_date, up_to_date) != :gt
      _ -> false
    end
  end
end
