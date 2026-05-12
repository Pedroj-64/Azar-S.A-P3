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

      <%!-- Financial Summary --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <.stat_card title="Ingresos" value={"$#{fmt(@balance.summary.total_revenue)}"} icon_name="hero-arrow-up-circle" color="emerald" />
        <.stat_card title="Premios" value={"$#{fmt(@balance.summary.total_prizes)}"} icon_name="hero-gift" color="yellow" />
        <.stat_card title="Ganancia" value={"$#{fmt(@balance.summary.total_profit)}"} icon_name="hero-scale" color={if @balance.summary.total_profit >= 0, do: "emerald", else: "red"} />
      </div>

      <%!-- Per-Draw Balance --%>
      <.glass_card class="mb-8">
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">Balance por Sorteo</h2>
        <div :if={@balance.draws == []}><.empty_state message="Sin sorteos ejecutados" /></div>
        <div class="overflow-x-auto">
          <table :if={@balance.draws != []} class="w-full font-mono text-sm">
            <thead>
              <tr style="border-bottom: 1px solid rgba(212,160,23,0.2);">
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">Sorteo</th>
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">Fecha</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">Ingresos</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">Premios</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">Ganancia</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={d <- @balance.draws} style="border-bottom: 1px solid rgba(212,160,23,0.06);" class="hover:bg-[rgba(212,160,23,0.04)] transition-colors">
                <td class="py-3 px-2 text-[var(--crema)]">{d.name}</td>
                <td class="py-3 px-2 text-[var(--crema-oscura)]">{d.date}</td>
                <td class="py-3 px-2 text-right text-[var(--teal-lt)]">${fmt(d.revenue)}</td>
                <td class="py-3 px-2 text-right text-[var(--mostaza)]">${fmt(d.total_prizes)}</td>
                <td class={["py-3 px-2 text-right font-bold", d.profit >= 0 && "text-[var(--teal-lt)]", d.profit < 0 && "text-[var(--naranja)]"]}>
                  ${fmt(d.profit)}
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </.glass_card>

      <%!-- Delivered Prizes --%>
      <.glass_card>
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">Premios Entregados</h2>
        <div :if={@prizes == []}><.empty_state icon_name="hero-trophy" message="Sin premios entregados" /></div>
        <div :for={p <- @prizes} class="flex items-center justify-between p-3 mb-2"
          style="border-radius: 2px; background: rgba(90,46,16,0.2); border: 1px solid rgba(212,160,23,0.08);">
          <div>
            <span class="text-[var(--crema)] font-medium">{p.prize_name}</span>
            <span class="font-mono text-xs text-[var(--crema-oscura)] ml-2">({p.draw_name})</span>
          </div>
          <span class="font-display text-[var(--mostaza)]">${fmt(p.amount)}</span>
        </div>
      </.glass_card>
    </div>
    """
  end
end
