defmodule ProyectoWeb.Admin.ReportsLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    balance = CentralServer.get_draws_balance()
    prizes = CentralServer.get_delivered_prizes()
    {:ok, assign(socket, page_title: "Reportes", balance: balance, prizes: prizes)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title="Reportes" subtitle="Balance financiero y premios entregados" />

      <!-- Financial Summary -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <.stat_card title="Ingresos" value={"$#{fmt(@balance.summary.total_revenue)}"} icon_name="hero-arrow-up-circle" color="emerald" />
        <.stat_card title="Premios" value={"$#{fmt(@balance.summary.total_prizes)}"} icon_name="hero-gift" color="yellow" />
        <.stat_card title="Ganancia" value={"$#{fmt(@balance.summary.total_profit)}"} icon_name="hero-scale" color={if @balance.summary.total_profit >= 0, do: "emerald", else: "red"} />
      </div>

      <!-- Per-Draw Balance -->
      <.glass_card class="mb-8">
        <h2 class="text-xl font-bold text-white mb-4">Balance por Sorteo</h2>
        <div :if={@balance.draws == []}><.empty_state message="Sin sorteos ejecutados" /></div>
        <div class="overflow-x-auto">
          <table :if={@balance.draws != []} class="w-full text-sm">
            <thead>
              <tr class="border-b border-white/10 text-slate-400">
                <th class="text-left py-3 px-2">Sorteo</th>
                <th class="text-left py-3 px-2">Fecha</th>
                <th class="text-right py-3 px-2">Ingresos</th>
                <th class="text-right py-3 px-2">Premios</th>
                <th class="text-right py-3 px-2">Ganancia</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={d <- @balance.draws} class="border-b border-white/5 hover:bg-white/5">
                <td class="py-3 px-2 text-white">{d.name}</td>
                <td class="py-3 px-2 text-slate-400">{d.date}</td>
                <td class="py-3 px-2 text-right text-emerald-400">${fmt(d.revenue)}</td>
                <td class="py-3 px-2 text-right text-yellow-400">${fmt(d.total_prizes)}</td>
                <td class={["py-3 px-2 text-right font-bold", d.profit >= 0 && "text-emerald-400", d.profit < 0 && "text-red-400"]}>
                  ${fmt(d.profit)}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </.glass_card>

      <!-- Delivered Prizes -->
      <.glass_card>
        <h2 class="text-xl font-bold text-white mb-4">Premios Entregados</h2>
        <div :if={@prizes == []}><.empty_state icon_name="hero-trophy" message="Sin premios entregados" /></div>
        <div :for={p <- @prizes} class="flex items-center justify-between p-3 rounded-xl bg-slate-700/30 mb-2">
          <div>
            <span class="text-white font-medium">{p.prize_name}</span>
            <span class="text-slate-400 text-xs ml-2">({p.draw_name})</span>
          </div>
          <span class="text-yellow-400 font-bold">${fmt(p.amount)}</span>
        </div>
      </.glass_card>
    </div>
    """
  end

  defp fmt(n) when is_integer(n), do: n |> Integer.to_string() |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  defp fmt(_), do: "0"
end
