defmodule ProyectoWeb.Admin.ReportsLive do
  @moduledoc """
  Reportes financieros del administrador.
  Muestra balance por sorteo, premios entregados con nombres de ganadores,
  valor por fracción, y ganancias/pérdidas totales.
  """
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    balance = CentralServer.get_draws_balance()
    prizes = CentralServer.get_delivered_prizes()
    {:ok, assign(socket, page_title: gettext("reports_title"), balance: balance, prizes: prizes)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title={gettext("reports_title")} subtitle={gettext("reports_subtitle")} />

      <%!-- Financial Summary --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <.stat_card title={gettext("stat_revenue")} value={"$#{fmt(@balance.summary.total_revenue)}"} icon_name="hero-arrow-up-circle" color="emerald" />
        <.stat_card title={gettext("stat_prizes")} value={"$#{fmt(@balance.summary.total_prizes)}"} icon_name="hero-gift" color="yellow" />
        <.stat_card title={gettext("stat_profit")} value={"$#{fmt(@balance.summary.total_profit)}"} icon_name="hero-scale" color={if @balance.summary.total_profit >= 0, do: "emerald", else: "red"} />
      </div>

      <%!-- Per-Draw Balance --%>
      <.glass_card class="mb-8">
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">{gettext("reports_balance_title")}</h2>
        <div :if={@balance.draws == []}><.empty_state message={gettext("reports_balance_empty")} /></div>
        <div class="overflow-x-auto">
          <table :if={@balance.draws != []} class="w-full font-mono text-sm">
            <thead>
              <tr style="border-bottom: 1px solid rgba(212,160,23,0.2);">
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_draw")}</th>
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_date")}</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_revenue")}</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_prizes")}</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_profit")}</th>
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

      <%!-- Delivered Prizes (with winner names and fractional values) --%>
      <.glass_card>
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">{gettext("reports_delivered_title")}</h2>
        <div :if={@prizes == []}><.empty_state icon_name="hero-trophy" message={gettext("reports_delivered_empty")} /></div>

        <div class="overflow-x-auto">
          <table :if={@prizes != []} class="w-full font-mono text-sm">
            <thead>
              <tr style="border-bottom: 1px solid rgba(212,160,23,0.2);">
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_prize_name")}</th>
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_draw")}</th>
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_winner")}</th>
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_winning_number")}</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_amount")}</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_per_fraction")}</th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">{gettext("reports_col_revenue")}</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={p <- @prizes} style="border-bottom: 1px solid rgba(212,160,23,0.06);" class="hover:bg-[rgba(212,160,23,0.04)] transition-colors">
                <td class="py-3 px-2 text-[var(--crema)] font-medium">{p.prize_name}</td>
                <td class="py-3 px-2 text-[var(--crema-oscura)]">{p.draw_name}</td>
                <td class="py-3 px-2 text-[var(--teal-lt)]">{p.winner_name}</td>
                <td class="py-3 px-2 text-[var(--crema-oscura)]">#{p.winner_number}</td>
                <td class="py-3 px-2 text-right text-[var(--mostaza)]">${fmt(p.amount)}</td>
                <td class="py-3 px-2 text-right text-[var(--crema-oscura)]">${fmt(p.amount_per_fraction)}</td>
                <td class="py-3 px-2 text-right text-[var(--teal-lt)]">${fmt(p.revenue)}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </.glass_card>
    </div>
    """
  end
end
