defmodule ProyectoWeb.Admin.ReportsLive do
  @moduledoc """
  Reportes financieros del administrador.
  Muestra balance por sorteo, premios entregados con nombres de ganadores,
  valor por fracción, y ganancias/pérdidas totales.
  Incluye sorting por columnas en ambas tablas.
  """
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    balance = CentralServer.get_draws_balance()
    prizes = CentralServer.get_delivered_prizes()
    {:ok, assign(socket,
      page_title: gettext("reports_title"),
      balance: balance,
      prizes: prizes,
      sorted_balance: balance.draws,
      sorted_prizes: prizes,
      balance_sort: "date",
      balance_dir: "asc",
      prize_sort: "draw",
      prize_dir: "asc"
    )}
  end

  @impl true
  def handle_event("sort_balance", %{"by" => field}, socket) do
    current = socket.assigns.balance_sort
    dir = if field == current && socket.assigns.balance_dir == "asc", do: "desc", else: "asc"
    sorted = sort_balance(socket.assigns.balance.draws, field, dir)
    {:noreply, assign(socket, sorted_balance: sorted, balance_sort: field, balance_dir: dir)}
  end

  @impl true
  def handle_event("sort_prizes", %{"by" => field}, socket) do
    current = socket.assigns.prize_sort
    dir = if field == current && socket.assigns.prize_dir == "asc", do: "desc", else: "asc"
    sorted = sort_prizes(socket.assigns.prizes, field, dir)
    {:noreply, assign(socket, sorted_prizes: sorted, prize_sort: field, prize_dir: dir)}
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
        <div :if={@sorted_balance == []}><.empty_state message={gettext("reports_balance_empty")} /></div>
        <div class="overflow-x-auto">
          <table :if={@sorted_balance != []} class="w-full font-mono text-sm">
            <thead>
              <tr style="border-bottom: 1px solid rgba(212,160,23,0.2);">
                <.sort_th field="name" current={@balance_sort} dir={@balance_dir} event="sort_balance">
                  {gettext("reports_col_draw")}
                </.sort_th>
                <.sort_th field="date" current={@balance_sort} dir={@balance_dir} event="sort_balance">
                  {gettext("reports_col_date")}
                </.sort_th>
                <.sort_th field="revenue" current={@balance_sort} dir={@balance_dir} event="sort_balance" align="right">
                  {gettext("reports_col_revenue")}
                </.sort_th>
                <.sort_th field="prizes" current={@balance_sort} dir={@balance_dir} event="sort_balance" align="right">
                  {gettext("reports_col_prizes")}
                </.sort_th>
                <.sort_th field="profit" current={@balance_sort} dir={@balance_dir} event="sort_balance" align="right">
                  {gettext("reports_col_profit")}
                </.sort_th>
              </tr>
            </thead>
            <tbody>
              <tr :for={d <- @sorted_balance} style="border-bottom: 1px solid rgba(212,160,23,0.06);" class="hover:bg-[rgba(212,160,23,0.04)] transition-colors">
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
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">{gettext("reports_delivered_title")}</h2>
        <div :if={@sorted_prizes == []}><.empty_state icon_name="hero-trophy" message={gettext("reports_delivered_empty")} /></div>

        <div class="overflow-x-auto">
          <table :if={@sorted_prizes != []} class="w-full font-mono text-sm">
            <thead>
              <tr style="border-bottom: 1px solid rgba(212,160,23,0.2);">
                <.sort_th field="prize" current={@prize_sort} dir={@prize_dir} event="sort_prizes">
                  {gettext("reports_col_prize_name")}
                </.sort_th>
                <.sort_th field="draw" current={@prize_sort} dir={@prize_dir} event="sort_prizes">
                  {gettext("reports_col_draw")}
                </.sort_th>
                <.sort_th field="winner" current={@prize_sort} dir={@prize_dir} event="sort_prizes">
                  {gettext("reports_col_winner")}
                </.sort_th>
                <th class="text-left py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">
                  {gettext("reports_col_winning_number")}
                </th>
                <.sort_th field="amount" current={@prize_sort} dir={@prize_dir} event="sort_prizes" align="right">
                  {gettext("reports_col_amount")}
                </.sort_th>
                <th class="text-right py-3 px-2 text-[var(--crema-oscura)] text-xs uppercase tracking-widest">
                  {gettext("reports_col_per_fraction")}
                </th>
                <.sort_th field="revenue" current={@prize_sort} dir={@prize_dir} event="sort_prizes" align="right">
                  {gettext("reports_col_revenue")}
                </.sort_th>
              </tr>
            </thead>
            <tbody>
              <tr :for={p <- @sorted_prizes} style="border-bottom: 1px solid rgba(212,160,23,0.06);" class="hover:bg-[rgba(212,160,23,0.04)] transition-colors">
                <td class="py-3 px-2 text-[var(--crema)] font-medium">{p.prize_name}</td>
                <td class="py-3 px-2 text-[var(--crema-oscura)]">{p.draw_name}</td>
                <td class="py-3 px-2 text-[var(--teal-lt)]">{p.winner_name}</td>
                <td class="py-3 px-2 text-[var(--crema-oscura)]">#{p.winner_number}</td>
                <td class="py-3 px-2 text-right text-[var(--mostaza)] font-bold">${fmt(p.amount)}</td>
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

  # ── Sortable Table Header Component ────────────────────────

  attr :field, :string, required: true
  attr :current, :string, required: true
  attr :dir, :string, required: true
  attr :event, :string, required: true
  attr :align, :string, default: "left"
  slot :inner_block, required: true

  defp sort_th(assigns) do
    ~H"""
    <th class={"py-3 px-2 text-#{@align} text-xs uppercase tracking-widest cursor-pointer select-none transition-colors " <>
      if(@field == @current,
        do: "text-[var(--mostaza)]",
        else: "text-[var(--crema-oscura)] hover:text-[var(--mostaza)]"
      )}
      phx-click={@event}
      phx-value-by={@field}
    >
      {render_slot(@inner_block)}
      <span :if={@field == @current} class="ml-0.5 text-[0.55rem]">{if @dir == "asc", do: "↑", else: "↓"}</span>
    </th>
    """
  end

  # ── Sort Helpers ────────────────────────────────────────────

  defp sort_balance(draws, field, dir) do
    sorted = case field do
      "name" -> Enum.sort_by(draws, & &1.name)
      "date" -> Enum.sort_by(draws, & (&1.date || ""))
      "revenue" -> Enum.sort_by(draws, & &1.revenue)
      "prizes" -> Enum.sort_by(draws, & &1.total_prizes)
      "profit" -> Enum.sort_by(draws, & &1.profit)
      _ -> draws
    end
    if dir == "desc", do: Enum.reverse(sorted), else: sorted
  end

  defp sort_prizes(prizes, field, dir) do
    sorted = case field do
      "prize" -> Enum.sort_by(prizes, & &1.prize_name)
      "draw" -> Enum.sort_by(prizes, & &1.draw_name)
      "winner" -> Enum.sort_by(prizes, & &1.winner_name)
      "amount" -> Enum.sort_by(prizes, & &1.amount)
      "revenue" -> Enum.sort_by(prizes, & &1.revenue)
      _ -> prizes
    end
    if dir == "desc", do: Enum.reverse(sorted), else: sorted
  end
end
