defmodule ProyectoWeb.Admin.DashboardLive do
  @moduledoc """
  Dashboard principal del administrador.
  Muestra resumen financiero, fecha del sistema y últimos sorteos.
  """
  use ProyectoWeb, :live_view

  alias AzarSa.Core.Servers.CentralServer
  alias AzarSa.Core.Support.SystemDate

  @impl true
  def mount(_params, _session, socket) do
    balance = CentralServer.get_draws_balance()
    date = SystemDate.get_date()
    draws = CentralServer.list_draws()

    pending_count = Enum.count(draws, &(&1["status"] == "pending"))
    done_count = Enum.count(draws, &(&1["status"] == "done"))

    {:ok,
     assign(socket,
       page_title: "Dashboard",
       balance: balance,
       system_date: date,
       pending_count: pending_count,
       done_count: done_count,
       recent_draws: Enum.take(draws, -5) |> Enum.reverse()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header
        title="Dashboard"
        subtitle={"Fecha del sistema: #{@system_date}"}
      />

      <%!-- Stats Grid --%>
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <.stat_card
          title="Ingresos Totales"
          value={"$#{fmt(@balance.summary.total_revenue)}"}
          icon_name="hero-banknotes"
          color="emerald"
        />
        <.stat_card
          title="Premios Entregados"
          value={"$#{fmt(@balance.summary.total_prizes)}"}
          icon_name="hero-gift"
          color="yellow"
        />
        <.stat_card
          title="Ganancia Neta"
          value={"$#{fmt(@balance.summary.total_profit)}"}
          icon_name="hero-arrow-trending-up"
          color={if @balance.summary.total_profit >= 0, do: "emerald", else: "red"}
        />
        <.stat_card
          title="Sorteos Pendientes"
          value={to_string(@pending_count)}
          icon_name="hero-clock"
          color="blue"
        />
      </div>

      <%!-- Recent Draws --%>
      <.glass_card>
        <div class="flex items-center justify-between mb-6">
          <h2 class="font-display text-xl text-[var(--crema)]">Sorteos Recientes</h2>
          <.link navigate={~p"/admin/draws"} class="font-mono text-xs uppercase tracking-widest text-[var(--mostaza)] hover:neon-gold transition-all">
            Ver todos →
          </.link>
        </div>

        <div :if={@recent_draws == []} class="text-center py-8">
          <.empty_state icon_name="hero-ticket" message="No hay sorteos creados aún" />
        </div>

        <div :if={@recent_draws != []} class="space-y-3">
          <div :for={draw <- @recent_draws}
            class="flex items-center justify-between p-4"
            style="border-radius: 2px; background: rgba(90,46,16,0.25); border: 1px solid rgba(212,160,23,0.1);">
            <div class="flex items-center gap-4">
              <div class="p-2" style="background: rgba(212,160,23,0.1); border-radius: 2px;">
                <.icon name="hero-ticket" class="w-5 h-5 text-[var(--mostaza)]" />
              </div>
              <div>
                <p class="text-[var(--crema)] font-semibold">{draw["name"]}</p>
                <p class="font-mono text-xs text-[var(--crema-oscura)]">{draw["date"] || "Sin fecha"}</p>
              </div>
            </div>
            <div class="flex items-center gap-4">
              <span class="font-mono text-sm text-[var(--crema-oscura)]">${fmt(draw["ticket_price"] || 0)}</span>
              <.status_badge status={to_string(draw["status"] || "pending")} />
            </div>
          </div>
        </div>
      </.glass_card>
    </div>
    """
  end
end
