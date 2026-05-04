defmodule AzarSa.Core.Servers.CentralServer do
  @moduledoc """
  Servidor central del sistema Azar S.A.

  Actúa como fachada única. Se ha optimizado para que las operaciones de los sorteos
  se realicen directamente sobre los procesos DrawServer (descentralización),
  evitando que este servidor sea un cuello de botella.
  """

  use GenServer

  alias AzarSa.Core.Services.ClientService
  alias AzarSa.Core.Services.DrawService
  alias AzarSa.Core.Servers.DrawSupervisor
  alias AzarSa.Core.Servers.DrawServer
  alias AzarSa.Core.Support.AuditLogger

  ## 🚀 API pública — Optimizada (Bypass del proceso CentralServer para escalar)

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  # --- Clientes (Pasan por CentralServer para consistencia) ---

  def register_client(name, document, password, card) do
    GenServer.call(__MODULE__, {:register, name, document, password, card})
  end

  def authenticate_client(document, password) do
    GenServer.call(__MODULE__, {:login_client, document, password})
  end

  def authenticate_admin(username, password) do
    GenServer.call(__MODULE__, {:login_admin, username, password})
  end

  def list_clients do
    GenServer.call(__MODULE__, :list_clients)
  end

  def get_client_balance(client_id) do
    GenServer.call(__MODULE__, {:balance, client_id})
  end

  def get_client_draws(client_id) do
    GenServer.call(__MODULE__, {:get_client_draws, client_id})
  end

  def get_client_prizes(client_id) do
    GenServer.call(__MODULE__, {:get_client_prizes, client_id})
  end

  # --- Sorteos (Bypass CentralServer Process -> Direct to DrawServer) ---

  def create_draw(draw_id, name, date, ticket_price, fractions, total_tickets) do
    GenServer.call(__MODULE__, {:create_draw, draw_id, name, date, ticket_price, fractions, total_tickets})
  end

  def get_draw(draw_id) do
    result = try_call(draw_id, fn -> DrawServer.get_draw(draw_id) end)
    log_op("get_draw(#{draw_id})", result)
    result
  end

  def list_draws do
    result = DrawService.list_draws_sorted()
    AuditLogger.log_ok("list_draws")
    result
  end

  def delete_draw(draw_id) do
    result = try_call(draw_id, fn -> DrawServer.delete_draw(draw_id) end)

    if result == :ok do
      DrawSupervisor.stop_draw_by_id(draw_id)
    end

    log_op("delete_draw(#{draw_id})", result)
    result
  end

  def run_draw(draw_id) do
    result = try_call(draw_id, fn -> DrawServer.run_draw(draw_id) end)
    log_op("run_draw(#{draw_id})", result)
    result
  end

  def get_draw_clients(draw_id) do
    result = try_call(draw_id, fn -> DrawServer.get_clients(draw_id) end)
    log_op("get_draw_clients(#{draw_id})", result)
    result
  end

  def get_draw_revenue(draw_id) do
    result = try_call(draw_id, fn -> DrawServer.get_revenue(draw_id) end)
    log_op("get_draw_revenue(#{draw_id})", result)
    result
  end

  def get_draws_balance do
    result = DrawService.get_draws_balance()
    AuditLogger.log_ok("get_draws_balance")
    result
  end

  def get_available_numbers(draw_id) do
    result = try_call(draw_id, fn -> DrawServer.get_available_numbers(draw_id) end)
    log_op("get_available_numbers(#{draw_id})", result)
    result
  end

  # --- Tickets ---

  def buy_ticket(draw_id, client_id, number, fraction \\ :full) do
    result = try_call(draw_id, fn -> DrawServer.buy_ticket(draw_id, client_id, number, fraction) end)
    log_op("buy_ticket(#{draw_id}, #{client_id}, #{number})", result)
    result
  end

  def return_ticket(draw_id, client_id, number) do
    result = try_call(draw_id, fn -> DrawServer.return_ticket(draw_id, client_id, number) end)
    log_op("return_ticket(#{draw_id}, #{client_id}, #{number})", result)
    result
  end

  # --- Premios ---

  def add_prize(draw_id, name, amount) do
    result = try_call(draw_id, fn -> DrawServer.add_prize(draw_id, name, amount) end)
    log_op("add_prize(#{draw_id}, #{name})", result)
    result
  end

  def delete_prize(draw_id, prize_id) do
    result = try_call(draw_id, fn -> DrawServer.delete_prize(draw_id, prize_id) end)
    log_op("delete_prize(#{draw_id}, #{prize_id})", result)
    result
  end

  def get_delivered_prizes do
    result = DrawService.get_delivered_prizes()
    AuditLogger.log_ok("get_delivered_prizes")
    result
  end

  ## 🔹 Callbacks

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:register, name, document, password, card}, _from, state) do
    result = ClientService.register(name, document, password, card)
    log_op("register_client(#{document})", result)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:login_client, document, password}, _from, state) do
    result = ClientService.authenticate(document, password)
    log_op("authenticate_client(#{document})", result)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:login_admin, username, password}, _from, state) do
    result = AzarSa.Core.Services.AdminService.authenticate(username, password)
    log_op("authenticate_admin(#{username})", result)
    {:reply, result, state}
  end

  @impl true
  def handle_call(:list_clients, _from, state) do
    result = ClientService.list()
    AuditLogger.log_ok("list_clients")
    {:reply, result, state}
  end

  @impl true
  def handle_call({:balance, client_id}, _from, state) do
    result = ClientService.get_balance(client_id)
    log_op("get_client_balance(#{client_id})", result)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_client_draws, client_id}, _from, state) do
    result = ClientService.get_client_draws(client_id)
    log_op("get_client_draws(#{client_id})", result)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:get_client_prizes, client_id}, _from, state) do
    result = DrawService.get_prizes_won_by(client_id)
    log_op("get_client_prizes(#{client_id})", result)
    {:reply, result, state}
  end

  @impl true
  def handle_call({:create_draw, draw_id, name, date, ticket_price, fractions, total_tickets}, _from, state) do
    result =
      case DrawSupervisor.start_draw(draw_id, name, date, ticket_price, fractions, total_tickets) do
        {:ok, _pid} -> {:ok, draw_id}
        {:error, {:already_started, _pid}} -> {:error, :draw_already_exists}
        error -> error
      end

    log_op("create_draw(#{draw_id})", result)
    {:reply, result, state}
  end

  ## 🔹 Helpers

  defp try_call(_draw_id, fun) do
    try do
      fun.()
    catch
      :exit, _ -> {:error, :draw_not_found}
    end
  end

  defp log_op(operation, {:ok, _}), do: AuditLogger.log_ok(operation)
  defp log_op(operation, {:error, reason}), do: AuditLogger.log_error(operation, reason)
  defp log_op(operation, :ok), do: AuditLogger.log_ok(operation)
  defp log_op(operation, result), do: AuditLogger.log_ok(operation, inspect(result))
end
