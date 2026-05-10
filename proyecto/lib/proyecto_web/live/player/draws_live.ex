defmodule ProyectoWeb.Player.DrawsLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    draws = CentralServer.list_draws() |> Enum.filter(&(&1["status"] == "pending"))
    {:ok, assign(socket, page_title: "Sorteos", draws: draws)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title="Sorteos Disponibles" subtitle="Elige un sorteo y compra tu billete" />
      <div :if={@draws == []}><.glass_card><.empty_state icon_name="hero-ticket" message="No hay sorteos disponibles en este momento" /></.glass_card></div>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <.link :for={draw <- @draws} navigate={~p"/player/draws/#{draw["id"]}"}
          class="group bg-slate-800/70 backdrop-blur-md border border-white/10 rounded-2xl shadow-2xl overflow-hidden
                 hover:border-emerald-400/30 hover:shadow-emerald-500/10 transition-all duration-300">
          <img src={draw_img(draw)} class="w-full h-40 object-cover opacity-60 group-hover:opacity-80 transition" />
          <div class="p-5">
            <h3 class="text-lg font-bold text-white group-hover:text-emerald-400 transition-colors">{draw["name"]}</h3>
            <div class="flex items-center gap-4 mt-3 text-sm text-slate-400">
              <span><.icon name="hero-calendar" class="w-4 h-4 inline mr-1" />{draw["date"]}</span>
              <span><.icon name="hero-banknotes" class="w-4 h-4 inline mr-1" />${fmt(draw["ticket_price"] || 0)}</span>
            </div>
            <div class="flex items-center justify-between mt-4">
              <span class="text-xs text-slate-500">{draw["fractions"]} fracciones · {draw["total_tickets"]} billetes</span>
              <span class="text-emerald-400 text-sm font-semibold group-hover:translate-x-1 transition-transform">
                Jugar →
              </span>
            </div>
          </div>
        </.link>
      </div>
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
