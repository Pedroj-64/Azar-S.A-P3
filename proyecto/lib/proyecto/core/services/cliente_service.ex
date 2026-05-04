defmodule AzarSa.Core.Services.ClientService do
  alias AzarSa.Core.Domain.Client
  alias AzarSa.Core.Data.Store

  # @file is reserved in Elixir (points to the source file path). Use @clients_file instead.
  @clients_file "clients.json"

  # 🔹 Registrar cliente
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

  # 🔹 Login
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

  # 🔹 Obtener balance del cliente
  def get_balance(client_id) do
    draws = Store.list_draws()

    if not client_exists?(client_id) do
      {:error, :client_not_found}
    else
      {spent, won} =
        Enum.reduce(draws, {0, 0}, fn draw, {s, w} ->
          {s + spent_in_draw(draw, client_id), w + won_in_draw(draw, client_id)}
        end)

      {:ok,
       %{
         spent: spent,
         won: won,
         balance: won - spent
       }}
    end
  end

  # 🔹 Listar clientes
  def list do
    Store.read(@clients_file)
  end

  # 🔹 Helpers
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
    winner = result["winner_client_id"]

    if winner == client_id do
      total_prizes =
        (draw["prizes"] || [])
        |> Enum.reduce(0, fn p, acc -> acc + (p["amount"] || 0) end)

      total_prizes
    else
      0
    end
  end

  defp client_exists?(client_id) do
    clients = Store.read(@clients_file)
    Enum.any?(clients, fn c -> c["id"] == client_id end)
  end

  # 🔹 Listar sorteos
  def list_draws do
    draws = Store.list_draws()
    {:ok, draws}
  end

  # 🔹 Historial de sorteos del cliente
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
