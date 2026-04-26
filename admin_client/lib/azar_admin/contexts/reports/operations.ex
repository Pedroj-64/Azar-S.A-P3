defmodule AzarAdmin.Contexts.Reports.Operations do
  @moduledoc """
  Operaciones públicas de negocio para Reportes.

  Maneja la generación de:
  - Reportes financieros (ingresos, egresos, margen)
  - Análisis por sorteo (revenue, ganancias/pérdidas)
  - Estadísticas de jugadores (total registrados, activos, etc)
  - Resumen de premios pagados
  - Reportes de auditoría

  Integración:
  - Lee datos de JsonHelper
  - Usa cálculos de AzarShared.Calculations
  - Persiste reportes generados
  """

  alias AzarAdmin.Contexts.Reports.AdminReport
  alias AzarAdmin.Contexts.Reports.Schemas.{FinancialSummary, DrawAnalysis}
  alias AzarShared.JsonHelper

  @draws_file "priv/data/draws.json"
  @tickets_file "priv/data/tickets.json"
  @prizes_file "priv/data/prizes.json"
  @reports_file "priv/data/admin_reports.json"

  # ============================================================================
  # REPORTES FINANCIEROS
  # ============================================================================

  @doc """
  Genera un reporte financiero completo.

  Parámetros:
  - period_start: fecha inicial (DateTime)
  - period_end: fecha final (DateTime)
  - generated_by: ID del administrador que genera el reporte

  Incluye:
  - Total de ingresos
  - Total de premios pagados
  - Margen neto
  - Cantidad de sorteos
  - Rendimiento por sorteo

  Retorna:
  - {:ok, report} si se generó exitosamente
  - {:error, reason} si hay error
  """
  @spec generate_financial_report(DateTime.t(), DateTime.t(), String.t()) :: {:ok, AdminReport.t()} | {:error, term()}
  def generate_financial_report(period_start, period_end, generated_by) do
    with {:ok, draws} <- read_all_draws(),
         filtered_draws <- filter_draws_by_period(draws, period_start, period_end),
         {:ok, summary} <- calculate_financial_summary(filtered_draws) do
      report = AdminReport.new(%{
        title: "Financial Report - #{DateTime.to_date(period_start)} to #{DateTime.to_date(period_end)}",
        report_type: "financial",
        period_start: period_start,
        period_end: period_end,
        generated_by: generated_by,
        data: Map.from_struct(summary),
        summary: format_financial_summary(summary)
      })

      case JsonHelper.append_to_json_array(@reports_file, report) do
        :ok -> {:ok, report}
        error -> error
      end
    else
      error -> error
    end
  end

  @doc """
  Genera un análisis detallado de un sorteo específico.

  Incluye:
  - Ingresos totales
  - Billetes vendidos/disponibles
  - Premios pagados
  - Ganancias/Pérdidas
  - Información de ganadores

  Retorna:
  - {:ok, report} si se generó exitosamente
  - {:error, reason} si hay error
  """
  @spec generate_draw_analysis(String.t(), String.t()) :: {:ok, AdminReport.t()} | {:error, term()}
  def generate_draw_analysis(draw_id, generated_by) do
    with {:ok, draw} <- read_draw(draw_id),
         {:ok, tickets} <- read_draw_tickets(draw_id),
         {:ok, prizes} <- read_draw_prizes(draw_id),
         analysis <- DrawAnalysis.new(%{
           draw_id: draw.id,
           draw_name: draw.name,
           status: draw.status,
           total_revenue: calculate_draw_revenue(draw, tickets),
           tickets_sold: count_sold_tickets(tickets),
           total_tickets: draw.total_tickets,
           estimated_payout: calculate_total_payout(prizes),
           margin: calculate_draw_margin(draw, tickets, prizes),
           winning_numbers_count: if(draw.winning_numbers, do: length(draw.winning_numbers), else: 0)
         }) do
      report = AdminReport.new(%{
        title: "Draw Analysis - #{draw.name}",
        report_type: "draw_analysis",
        period_start: draw.created_at,
        period_end: draw.executed_at || DateTime.utc_now(),
        generated_by: generated_by,
        data: Map.from_struct(analysis)
      })

      case JsonHelper.append_to_json_array(@reports_file, report) do
        :ok -> {:ok, report}
        error -> error
      end
    else
      error -> error
    end
  end

  @doc """
  Genera un resumen de premios pagados en un período.

  Incluye:
  - Total de premios pagados
  - Cantidad de ganadores
  - Premios por tier
  - Sorteos con más premios pagados

  Retorna:
  - {:ok, report} si se generó exitosamente
  - {:error, reason} si hay error
  """
  @spec generate_prize_summary(DateTime.t(), DateTime.t(), String.t()) :: {:ok, AdminReport.t()} | {:error, term()}
  def generate_prize_summary(period_start, period_end, generated_by) do
    with {:ok, prizes} <- read_all_prizes(),
         filtered_prizes <- filter_prizes_by_period(prizes, period_start, period_end),
         summary <- calculate_prize_summary(filtered_prizes) do
      report = AdminReport.new(%{
        title: "Prize Summary - #{DateTime.to_date(period_start)} to #{DateTime.to_date(period_end)}",
        report_type: "prize_summary",
        period_start: period_start,
        period_end: period_end,
        generated_by: generated_by,
        data: summary
      })

      case JsonHelper.append_to_json_array(@reports_file, report) do
        :ok -> {:ok, report}
        error -> error
      end
    else
      error -> error
    end
  end

  # ============================================================================
  # CONSULTAR REPORTES
  # ============================================================================

  @doc """
  Obtiene un reporte por ID.

  Retorna:
  - {:ok, report} si el reporte existe
  - {:error, :not_found} si no existe
  """
  @spec get_report(String.t()) :: {:ok, AdminReport.t()} | {:error, term()}
  def get_report(report_id) do
    case JsonHelper.get_from_json(@reports_file, report_id) do
      {:ok, report_data} -> {:ok, AdminReport.new(report_data)}
      error -> error
    end
  end

  @doc """
  Lista todos los reportes generados.

  Retorna lista de struct AdminReport.
  """
  @spec list_reports() :: {:ok, [AdminReport.t()]} | {:error, term()}
  def list_reports do
    case JsonHelper.read_json(@reports_file) do
      {:ok, reports} ->
        reports_structs = Enum.map(reports, &AdminReport.new/1)
        {:ok, Enum.reverse(reports_structs)}

      error ->
        error
    end
  end

  @doc """
  Lista reportes por tipo.

  Tipos válidos: "financial", "draw_analysis", "player_stats", "prize_summary"

  Retorna:
  - {:ok, reports} si la consulta fue exitosa
  - {:error, reason} si hay error
  """
  @spec list_reports_by_type(String.t()) :: {:ok, [AdminReport.t()]} | {:error, term()}
  def list_reports_by_type(report_type) do
    with {:ok, reports} <- list_reports() do
      filtered = Enum.filter(reports, fn r -> r.report_type == report_type end)
      {:ok, filtered}
    else
      error -> error
    end
  end

  # ============================================================================
  # CÁLCULOS INTERNOS
  # ============================================================================

  defp calculate_financial_summary(draws) do
    summary = %{
      total_draws: length(draws),
      total_revenue: Enum.sum(Enum.map(draws, fn d -> d.total_revenue || 0 end)),
      total_premios: Enum.sum(Enum.map(draws, fn d -> d.total_premios || 0 end)),
      total_margin: Enum.sum(Enum.map(draws, fn d -> (d.total_revenue || 0) - (d.total_premios || 0) end)),
      draws_executed: Enum.count(draws, fn d -> d.status == "executed" end),
      draws_open: Enum.count(draws, fn d -> d.status == "open" end),
      draws_cancelled: Enum.count(draws, fn d -> d.status == "cancelled" end)
    }

    {:ok, FinancialSummary.new(summary)}
  end

  defp filter_draws_by_period(draws, period_start, period_end) do
    Enum.filter(draws, fn draw ->
      DateTime.compare(draw.created_at, period_start) in [:gt, :eq] and
        DateTime.compare(draw.created_at, period_end) in [:lt, :eq]
    end)
  end

  defp filter_prizes_by_period(prizes, period_start, period_end) do
    Enum.filter(prizes, fn prize ->
      DateTime.compare(prize.created_at, period_start) in [:gt, :eq] and
        DateTime.compare(prize.created_at, period_end) in [:lt, :eq]
    end)
  end

  defp calculate_draw_revenue(draw, tickets) do
    Enum.reduce(tickets, 0.0, fn ticket, acc ->
      if ticket[:sold], do: acc + draw.full_ticket_value, else: acc
    end)
  end

  defp count_sold_tickets(tickets) do
    Enum.count(tickets, fn t -> t[:sold] end)
  end

  defp calculate_total_payout(prizes) do
    Enum.reduce(prizes, 0.0, fn prize, acc ->
      acc + (prize[:amount] || 0)
    end)
  end

  defp calculate_draw_margin(draw, tickets, prizes) do
    revenue = calculate_draw_revenue(draw, tickets)
    payout = calculate_total_payout(prizes)
    revenue - payout
  end

  defp calculate_prize_summary(prizes) do
    %{
      total_prizes_paid: Enum.sum(Enum.map(prizes, fn p -> p[:amount] || 0 end)),
      prizes_by_tier: Enum.group_by(prizes, fn p -> p[:prize_tier] end),
      total_winners: Enum.sum(Enum.map(prizes, fn p -> p[:winners_count] || 0 end))
    }
  end

  defp format_financial_summary(summary) do
    """
    Financial Summary Report
    =======================
    Total Draws: #{summary.total_draws}
    Total Revenue: $#{Float.round(summary.total_revenue, 2)}
    Total Prizes: $#{Float.round(summary.total_premios, 2)}
    Net Margin: $#{Float.round(summary.total_margin, 2)}

    Draws by Status:
    - Open: #{summary.draws_open}
    - Executed: #{summary.draws_executed}
    - Cancelled: #{summary.draws_cancelled}
    """
  end

  # ============================================================================
  # LECTURAS DE DATOS AUXILIARES
  # ============================================================================

  defp read_all_draws do
    case JsonHelper.read_json(@draws_file) do
      {:ok, draws} -> {:ok, Enum.map(draws, fn d -> Map.put(d, :total_revenue, 0.0) end)}
      error -> error
    end
  end

  defp read_draw(draw_id) do
    case JsonHelper.get_from_json(@draws_file, draw_id) do
      {:ok, draw_data} -> {:ok, draw_data}
      error -> error
    end
  end

  defp read_draw_tickets(draw_id) do
    case JsonHelper.read_json(@tickets_file) do
      {:ok, tickets} ->
        filtered = Enum.filter(tickets, fn t -> t[:draw_id] == draw_id end)
        {:ok, filtered}

      error ->
        error
    end
  end

  defp read_draw_prizes(draw_id) do
    case JsonHelper.read_json(@prizes_file) do
      {:ok, prizes} ->
        filtered = Enum.filter(prizes, fn p -> p[:draw_id] == draw_id end)
        {:ok, filtered}

      error ->
        error
    end
  end

  defp read_all_prizes do
    JsonHelper.read_json(@prizes_file)
  end
end
