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

      <!-- Prizes Won -->
      <div :if={@prizes != []} class="mb-8 animate-fade-in-up">
        <.glass_card>
          <h2 class="text-xl font-bold text-yellow-400 mb-4">
            <.icon name="hero-trophy" class="w-6 h-6 inline mr-2" /> ¡Premios Ganados!
          </h2>
          <div :for={p <- @prizes} class="flex items-center justify-between p-4 rounded-xl bg-yellow-400/5 border border-yellow-400/10 mb-2">
            <div>
              <span class="text-white font-semibold">{p.prize_name}</span>
              <span class="text-slate-400 text-xs ml-2">({p.draw_name})</span>
            </div>
            <span class="text-yellow-400 font-bold text-lg">${fmt(p.amount)}</span>
          </div>
        </.glass_card>
      </div>

      <!-- Participated Draws -->
      <.glass_card>
        <h2 class="text-xl font-bold text-white mb-4">Sorteos en los que Participé</h2>
        <div :if={@draws == []}><.empty_state icon_name="hero-ticket" message="Aún no has participado en ningún sorteo" /></div>
        <div class="space-y-3">
          <div :for={draw <- @draws} class="flex items-center justify-between p-4 rounded-xl bg-slate-700/30 border border-white/5">
            <div class="flex items-center gap-4">
              <div class="bg-slate-600/50 p-2 rounded-lg">
                <.icon name="hero-ticket" class="w-5 h-5 text-slate-300" />
              </div>
              <div>
                <p class="text-white font-medium">{draw["name"]}</p>
                <p class="text-slate-400 text-xs">{draw["date"]}</p>
              </div>
            </div>
            <.status_badge status={to_string(draw["status"] || "pending")} />
          </div>
        </div>
      </.glass_card>
    </div>
    """
  end

  defp fmt(n) when is_integer(n), do: n |> Integer.to_string() |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  defp fmt(_), do: "0"
end
