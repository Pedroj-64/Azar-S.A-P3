defmodule ProyectoWeb.Admin.ClientsLive do
  @moduledoc """
  Lista de clientes registrados con sus balances.
  """
  use ProyectoWeb, :live_view

  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    clients = CentralServer.list_clients()

    clients_with_balance =
      Enum.map(clients, fn client ->
        balance =
          case CentralServer.get_client_balance(client["id"]) do
            {:ok, b} -> b
            _ -> %{spent: 0, won: 0, balance: 0}
          end

        Map.put(client, "balance_info", balance)
      end)

    {:ok,
     assign(socket,
       page_title: "Clientes",
       clients: clients_with_balance
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title="Clientes" subtitle={"#{length(@clients)} jugadores registrados"} />

      <div :if={@clients == []}>
        <.glass_card>
          <.empty_state icon_name="hero-users" message="No hay clientes registrados aún" />
        </.glass_card>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        <div :for={client <- @clients}>
          <.glass_card class="hover:border-white/20 transition-all duration-300">
            <div class="flex items-center gap-4 mb-4">
              <img src={~p"/images/avatar_default.svg"} class="w-12 h-12 rounded-xl" />
              <div>
                <h3 class="text-white font-semibold">{client["name"]}</h3>
                <p class="text-slate-400 text-xs">Doc: {client["document"]}</p>
              </div>
            </div>

            <div class="grid grid-cols-3 gap-2">
              <div class="bg-slate-700/30 rounded-lg p-3 text-center">
                <p class="text-xs text-slate-400">Gastado</p>
                <p class="text-sm font-bold text-red-400">
                  ${format_number(client["balance_info"].spent)}
                </p>
              </div>
              <div class="bg-slate-700/30 rounded-lg p-3 text-center">
                <p class="text-xs text-slate-400">Ganado</p>
                <p class="text-sm font-bold text-emerald-400">
                  ${format_number(client["balance_info"].won)}
                </p>
              </div>
              <div class="bg-slate-700/30 rounded-lg p-3 text-center">
                <p class="text-xs text-slate-400">Balance</p>
                <p class={[
                  "text-sm font-bold",
                  client["balance_info"].balance >= 0 && "text-emerald-400",
                  client["balance_info"].balance < 0 && "text-red-400"
                ]}>
                  ${format_number(client["balance_info"].balance)}
                </p>
              </div>
            </div>

            <p class="text-xs text-slate-500 mt-3">
              <.icon name="hero-calendar" class="w-3 h-3 inline" />
              Registrado: {client["created_at"] |> String.slice(0, 10)}
            </p>
          </.glass_card>
        </div>
      </div>
    </div>
    """
  end

  defp format_number(n) when is_integer(n) do
    n |> Integer.to_string() |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  end
  defp format_number(_), do: "0"
end
