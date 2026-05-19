defmodule AzarSa.Core.Services.ClientService do
  @moduledoc """
  Servicio para gestionar clientes.

  API pública:
  - register/4: Registra un nuevo cliente
  - authenticate/2: Autentica un cliente
  - get_balance/1: Obtiene el balance del cliente
  - list/0: Lista todos los clientes
  - list_draws/0: Lista todos los sorteos
  - get_client_draws/1: Obtiene los sorteos del cliente

  Helpers:
  - document_exists?/2: Verifica si existe un cliente por documento
  - hash/1: Hash de la contraseña
  - spent_in_draw/2: Calcula el gasto en un sorteo
  - won_in_draw/2: Calcula la ganancia en un sorteo
  - client_exists?/1: Verifica si existe un cliente por ID
  """
  alias AzarSa.Core.Domain.Client
  alias AzarSa.Core.Data.Store

  # @file is reserved in Elixir (points to the source file path). Use @clients_file instead.
  @clients_file "clients.json"

  # Registrar cliente
  def register(name, document, password, card) do
    clients = Store.read(@clients_file)

    if document_exists?(clients, document) do
      {:error, :document_exists}
    else
      client = Client.new(name, document, password, card)
      Store.write(@clients_file, [client | clients])
      {:ok, client}
    end
  end

  # Login
  def authenticate(document, password) do
    clients = Store.read(@clients_file)

    case Enum.find(clients, fn c -> c["document"] == document end) do
      nil ->
        {:error, :client_not_found}

      client ->
        if client["password_hash"] == hash(password) do
          {:ok, client}
        else
          {:error, :invalid_password}
        end
    end
  end

  #  Obtener balance del cliente (wallet + historial)
  def get_balance(client_id) do
    clients = Store.read(@clients_file)

    case Enum.find(clients, fn c -> c["id"] == client_id end) do
      nil ->
        {:error, :client_not_found}

      client ->
        draws = Store.list_draws()

        {spent, won} =
          Enum.reduce(draws, {0, 0}, fn draw, {s, w} ->
            {s + spent_in_draw(draw, client_id), w + won_in_draw(draw, client_id)}
          end)

        wallet = client["balance"] || 500_000

        {:ok,
         %{
           wallet: wallet,
           spent: spent,
           won: won,
           balance: won - spent,
           net_worth: wallet + won - spent
         }}
    end
  end

  # Deducir del balance del cliente (al comprar ticket)
  def deduct_balance(client_id, amount) do
    clients = Store.read(@clients_file)

    case Enum.find_index(clients, fn c -> c["id"] == client_id end) do
      nil ->
        {:error, :client_not_found}

      idx ->
        client = Enum.at(clients, idx)
        current = client["balance"] || 500_000

        if current < amount do
          {:error, :insufficient_balance}
        else
          updated = Map.put(client, "balance", current - amount)
          new_clients = List.replace_at(clients, idx, updated)
          Store.write(@clients_file, new_clients)
          {:ok, current - amount}
        end
    end
  end

  # Acreditar al balance del cliente (al devolver ticket o ganar premio)
  def credit_balance(client_id, amount) do
    clients = Store.read(@clients_file)

    case Enum.find_index(clients, fn c -> c["id"] == client_id end) do
      nil ->
        {:error, :client_not_found}

      idx ->
        client = Enum.at(clients, idx)
        current = client["balance"] || 500_000
        updated = Map.put(client, "balance", current + amount)
        new_clients = List.replace_at(clients, idx, updated)
        Store.write(@clients_file, new_clients)
        {:ok, current + amount}
    end
  end

  # Listar clientes
  def list do
    Store.read(@clients_file)
  end

  # Helpers
  defp document_exists?(clients, document) do
    Enum.any?(clients, fn c -> c["document"] == document end)
  end

  defp hash(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16(case: :lower)
  end

  defp spent_in_draw(draw, client_id) do
    fraction_price =
      div(
        draw["ticket_price"] || 10_000,
        max(draw["fractions"] || 1, 1)
      )

    (draw["tickets"] || %{})
    |> Enum.filter(fn {_key, ticket} ->
      case ticket do
        %{"client_id" => cid} -> cid == client_id
        cid when is_binary(cid) -> cid == client_id
        _ -> false
      end
    end)
    |> Enum.count()
    |> Kernel.*(fraction_price)
  end

  defp won_in_draw(draw, client_id) do
    result = draw["result"] || %{}
    prize_winners = result["prize_winners"] || []

    if prize_winners != [] do
      # Sumar todos los premios ganados por este cliente en este sorteo
      prize_winners
      |> Enum.filter(fn pw -> pw["winner_client_id"] == client_id end)
      |> Enum.reduce(0, fn pw, acc -> acc + (pw["prize_amount"] || 0) end)
    else
      # Fallback: compatibilidad con resultado simple (solo un ganador)
      if result["winner_client_id"] == client_id do
        (draw["prizes"] || [])
        |> Enum.reduce(0, fn p, acc -> acc + (p["amount"] || 0) end)
      else
        0
      end
    end
  end

  defp client_exists?(client_id) do
    clients = Store.read(@clients_file)
    Enum.any?(clients, fn c -> c["id"] == client_id end)
  end

  # Listar sorteos
  def list_draws do
    draws = Store.list_draws()
    {:ok, draws}
  end

  # Historial de sorteos del cliente
  def get_client_draws(client_id) do
    if not client_exists?(client_id) do
      {:error, :client_not_found}
    else
      draws = Store.list_draws()

      participated_draws =
        Enum.filter(draws, fn draw ->
          Enum.any?(draw["tickets"] || %{}, fn {_num, ticket_info} ->
            case ticket_info do
              %{"client_id" => cid} -> cid == client_id
              cid -> cid == client_id
            end
          end)
        end)

      {:ok, participated_draws}
    end
  end
end
