defmodule AzarSa.Core.Support.AuditLogger do
  @moduledoc """
  Servidor de bitácora del sistema.

  Registra TODAS las solicitudes del sistema con:
  - Fecha y hora (UTC)
  - Nombre de la operación
  - Resultado (:ok o :error)

  Salida doble:
  1. Pantalla (Logger de Elixir)
  2. Archivo de texto en priv/logs/bitacora.txt
  """

  use GenServer
  require Logger

  @log_file "priv/logs/bitacora.txt"

  ## API pública

  def start_link(_args) do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @doc "Registra una operación exitosa."
  def log_ok(operation, detail \\ nil) do
    GenServer.cast(__MODULE__, {:log, :ok, operation, detail})
  end

  @doc "Registra una operación rechazada o con error."
  def log_error(operation, reason, detail \\ nil) do
    GenServer.cast(__MODULE__, {:log, :error, operation, {reason, detail}})
  end

  ## Callbacks

  @impl true
  def init(:ok) do
    File.mkdir_p!(Path.dirname(@log_file))
    {:ok, :no_state}
  end

  @impl true
  def handle_cast({:log, result, operation, detail}, state) do
    timestamp = DateTime.utc_now() |> Calendar.strftime("%Y-%m-%d %H:%M:%S")
    result_tag = if result == :ok, do: "OK", else: "ERROR"

    detail_str =
      case detail do
        nil -> ""
        {reason, nil} -> " | razón: #{reason}"
        {reason, extra} -> " | razón: #{reason} | detalle: #{inspect(extra)}"
        other -> " | #{inspect(other)}"
      end

    line = "[#{timestamp}] #{result_tag} | #{operation}#{detail_str}"

    # 1. Mostrar en consola
    if result == :ok do
      Logger.info(line)
    else
      Logger.warning(line)
    end

    # 2. Guardar en archivo
    File.write!(@log_file, line <> "\n", [:append])

    {:noreply, state}
  end
end
