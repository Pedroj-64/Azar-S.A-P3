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
          <h2 class="text-xl font-bold text-white">Sorteos Disponibles</h2>
          <.link navigate={~p"/player/draws"} class="text-sm text-emerald-400 hover:text-emerald-300">Ver todos →</.link>
        </div>
        <div :if={@pending_draws == []}><.empty_state icon_name="hero-ticket" message="No hay sorteos disponibles" /></div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.link :for={draw <- @pending_draws} navigate={~p"/player/draws/#{draw["id"]}"}
            class="group p-4 rounded-xl bg-slate-700/30 border border-white/5 hover:border-emerald-400/30 transition-all">
            <img src={draw_img(draw)} class="w-full h-24 object-cover rounded-lg mb-3 opacity-70 group-hover:opacity-100 transition" />
            <h3 class="text-white font-semibold">{draw["name"]}</h3>
            <p class="text-slate-400 text-xs mt-1">{draw["date"]} — ${fmt(draw["ticket_price"] || 0)}</p>
          </.link>
        </div>
      </.glass_card>
    </div>
    """
  end

  defp draw_img(d) do
    p = d["ticket_price"] || 0
    cond do
      p >= 50_000 -> "/images/sorteo_oro.svg"
      p >= 20_000 -> "/images/sorteo_plata.svg"
      true -> "/images/sorteo_bronce.svg"
    end
  end

  defp fmt(n) when is_integer(n), do: n |> Integer.to_string() |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  defp fmt(_), do: "0"
end
