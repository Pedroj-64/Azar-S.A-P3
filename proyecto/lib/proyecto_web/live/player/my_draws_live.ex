defmodule ProyectoWeb.Player.MyDrawsLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    client_id = socket.assigns.client_id
    {:ok, draws} = CentralServer.get_client_draws(client_id)
    {:ok, prizes} = CentralServer.get_client_prizes(client_id)
    {:ok, assign(socket, page_title: "Mis Sorteos", draws: draws, prizes: prizes)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title="Mis Sorteos" subtitle="Historial de participación y premios ganados" />

      <%!-- Prizes Won --%>
      <div :if={@prizes != []} class="mb-8 page-enter">
        <.glass_card>
          <h2 class="font-display text-xl text-[var(--mostaza)] mb-4">
            <.icon name="hero-trophy" class="w-6 h-6 inline mr-2" /> ¡Premios Ganados!
          </h2>
          <div :for={p <- @prizes} class="flex items-center justify-between p-4 mb-2"
            style="border-radius: 2px; background: rgba(212,160,23,0.06); border: 1px solid rgba(212,160,23,0.15);">
            <div>
              <span class="text-[var(--crema)] font-semibold">{p.prize_name}</span>
              <span class="font-mono text-xs text-[var(--crema-oscura)] ml-2">({p.draw_name})</span>
            </div>
            <span class="font-display text-lg text-[var(--mostaza)] neon-gold">${fmt(p.amount)}</span>
          </div>
        </.glass_card>
      </div>

      <%!-- Participated Draws --%>
      <.glass_card>
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">Sorteos en los que Participé</h2>
        <div :if={@draws == []}><.empty_state icon_name="hero-ticket" message="Aún no has participado en ningún sorteo" /></div>
        <div class="space-y-3">
          <div :for={draw <- @draws} class="flex items-center justify-between p-4"
            style="border-radius: 2px; background: rgba(90,46,16,0.2); border: 1px solid rgba(212,160,23,0.08);">
            <div class="flex items-center gap-4">
              <div class="p-2" style="background: rgba(90,46,16,0.35); border-radius: 2px;">
                <.icon name="hero-ticket" class="w-5 h-5 text-[var(--crema-oscura)]" />
              </div>
              <div>
                <p class="text-[var(--crema)] font-medium">{draw["name"]}</p>
                <p class="font-mono text-xs text-[var(--crema-oscura)]">{draw["date"]}</p>
              </div>
            </div>
            <.status_badge status={to_string(draw["status"] || "pending")} />
          </div>
        </div>
      </.glass_card>
    </div>
    """
  end
end
