defmodule AzarSa.Core.Servers.DrawSupervisor do
  @moduledoc """
  Supervisor dinámico que gestiona los procesos de sorteo (DrawServer).

  Cada sorteo tiene exactamente un proceso hijo asociado.
  El supervisor se encarga de iniciarlos, detenerlos y mantenerlos vivos.
  """

  use DynamicSupervisor

  alias AzarSa.Core.Servers.DrawServer

  ## Inicio

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  ## API

  @doc "Inicia el proceso de un sorteo con todos sus parámetros de dominio."
  def start_draw(draw_id, name, date, ticket_price, fractions, total_tickets) do
    spec = {DrawServer, {draw_id, name, date, ticket_price, fractions, total_tickets}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  @doc "Detiene el proceso de un sorteo dado su PID."
  def stop_draw(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end

  @doc "Detiene el proceso de un sorteo dado su ID (busca el PID en el Registry)."
  def stop_draw_by_id(draw_id) do
    case Registry.lookup(AzarSa.DrawRegistry, draw_id) do
      [{pid, _}] -> stop_draw(pid)
      [] -> {:error, :draw_not_found}
    end
  end
end
