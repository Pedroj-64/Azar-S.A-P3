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
          <.glass_card class="hover:halo transition-all duration-300">
            <div class="flex items-center gap-4 mb-4">
              <img src={~p"/images/avatar_default.svg"} class="w-12 h-12" style="border-radius: 2px; border: 1px solid rgba(212,160,23,0.2);" />
              <div>
                <h3 class="text-[var(--crema)] font-semibold">{client["name"]}</h3>
                <p class="font-mono text-xs text-[var(--crema-oscura)]">Doc: {client["document"]}</p>
              </div>
            </div>

            <div class="grid grid-cols-3 gap-2">
              <div class="p-3 text-center" style="background: rgba(90,46,16,0.2); border-radius: 2px;">
                <p class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)]">Gastado</p>
                <p class="font-display text-sm text-[var(--naranja)]">
                  ${fmt(client["balance_info"].spent)}
                </p>
              </div>
              <div class="p-3 text-center" style="background: rgba(90,46,16,0.2); border-radius: 2px;">
                <p class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)]">Ganado</p>
                <p class="font-display text-sm text-[var(--teal-lt)]">
                  ${fmt(client["balance_info"].won)}
                </p>
              </div>
              <div class="p-3 text-center" style="background: rgba(90,46,16,0.2); border-radius: 2px;">
                <p class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)]">Balance</p>
                <p class={[
                  "font-display text-sm",
                  client["balance_info"].balance >= 0 && "text-[var(--teal-lt)]",
                  client["balance_info"].balance < 0 && "text-[var(--naranja)]"
                ]}>
                  ${fmt(client["balance_info"].balance)}
                </p>
              </div>
            </div>

            <p class="font-mono text-[0.6rem] text-[var(--crema-oscura)] mt-3 uppercase tracking-widest">
              <.icon name="hero-calendar" class="w-3 h-3 inline" />
              Registrado: {client["created_at"] |> String.slice(0, 10)}
            </p>
          </.glass_card>
        </div>
      </div>
    </div>
    """
  end
end
