defmodule ProyectoWeb.Player.DrawsLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    draws = CentralServer.list_draws() |> Enum.filter(&(&1["status"] == "pending"))
    {:ok, assign(socket, page_title: gettext("player_draws_title"), draws: draws)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title={gettext("player_draws_title")} subtitle={gettext("player_draws_subtitle")} />
      <div :if={@draws == []}>
        <.glass_card>
          <.empty_state icon_name="hero-ticket" message={gettext("player_draws_empty")} />
        </.glass_card>
      </div>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <.link :for={draw <- @draws} navigate={~p"/player/draws/#{draw["id"]}"}
          class="group vintage-card overflow-hidden hover:halo transition-all duration-300">
          <img src={draw_img(draw)} class="w-full h-40 object-cover opacity-60 group-hover:opacity-80 transition" />
          <div class="p-5">
            <h3 class="font-display text-lg text-[var(--crema)] group-hover:text-[var(--mostaza)] transition-colors">{draw["name"]}</h3>
            <div class="flex items-center gap-4 mt-3 font-mono text-xs text-[var(--crema-oscura)]">
              <span><.icon name="hero-calendar" class="w-4 h-4 inline mr-1" />{draw["date"]}</span>
              <span><.icon name="hero-banknotes" class="w-4 h-4 inline mr-1" />${fmt(draw["ticket_price"] || 0)}</span>
            </div>
            <div class="flex items-center justify-between mt-4">
              <span class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)]">
                {gettext("draw_fractions_tickets",
                  fractions: draw["fractions"],
                  tickets: draw["total_tickets"]
                )}
              </span>
              <span class="text-[var(--teal-lt)] font-mono text-sm group-hover:translate-x-1 transition-transform">
                {gettext("draw_play_btn")}
              </span>
            </div>
          </div>
        </.link>
      </div>
    </div>
    """
  end
end
