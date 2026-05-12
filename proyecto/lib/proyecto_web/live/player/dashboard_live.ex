defmodule ProyectoWeb.Player.DashboardLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    client_id = socket.assigns.client_id
    {:ok, balance} = CentralServer.get_client_balance(client_id)
    draws = CentralServer.list_draws()
    pending = Enum.filter(draws, &(&1["status"] == "pending")) |> Enum.take(3)

    {:ok, assign(socket, page_title: "Inicio", balance: balance, pending_draws: pending)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title={"¡Hola, #{@client_name || "Jugador"}!"} subtitle="Tu resumen personal" />

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <.stat_card title="Total Gastado" value={"$#{fmt(@balance.spent)}"} icon_name="hero-shopping-cart" color="red" />
        <.stat_card title="Total Ganado" value={"$#{fmt(@balance.won)}"} icon_name="hero-trophy" color="yellow" />
        <.stat_card title="Balance Neto" value={"$#{fmt(@balance.balance)}"} icon_name="hero-scale"
          color={if @balance.balance >= 0, do: "emerald", else: "red"} />
      </div>

      <.glass_card>
        <div class="flex items-center justify-between mb-6">
          <h2 class="font-display text-xl text-[var(--crema)]">Sorteos Disponibles</h2>
          <.link navigate={~p"/player/draws"} class="font-mono text-xs uppercase tracking-widest text-[var(--teal-lt)] hover:neon-teal transition-all">Ver todos →</.link>
        </div>
        <div :if={@pending_draws == []}><.empty_state icon_name="hero-ticket" message="No hay sorteos disponibles" /></div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.link :for={draw <- @pending_draws} navigate={~p"/player/draws/#{draw["id"]}"}
            class="group p-4 vintage-card hover:halo transition-all duration-300">
            <img src={draw_img(draw)} class="w-full h-24 object-cover mb-3 opacity-70 group-hover:opacity-100 transition" style="border-radius: 2px;" />
            <h3 class="text-[var(--crema)] font-semibold group-hover:text-[var(--mostaza)] transition-colors">{draw["name"]}</h3>
            <p class="font-mono text-xs text-[var(--crema-oscura)] mt-1">{draw["date"]} — ${fmt(draw["ticket_price"] || 0)}</p>
          </.link>
        </div>
      </.glass_card>
    </div>
    """
  end
end
