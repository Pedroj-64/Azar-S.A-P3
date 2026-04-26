defmodule AzarAdmin.Controllers.ReportController do
  @moduledoc """
  Controller para generación y consulta de reportes.

  Proporciona endpoints para:
  - Generar reportes financieros
  - Generar análisis por sorteo
  - Generar resumen de premios
  - Listar reportes generados
  - Obtener detalles de un reporte
  """

  use Phoenix.Controller

  alias AzarAdmin.Contexts.Reports.Operations, as: ReportOps
  alias AzarShared.Errors

  @doc """
  Genera un reporte financiero completo.

  Parámetros:
  - period_start: DateTime - fecha inicial del período
  - period_end: DateTime - fecha final del período
  - generated_by: String - ID del admin que genera el reporte

  Retorna:
  - 201 Created: Reporte generado exitosamente
  - 400 Bad Request: Validación fallida
  - 500 Error: Error en servidor
  """
  def generate_financial_report(conn, %{
    "period_start" => period_start,
    "period_end" => period_end,
    "generated_by" => generated_by
  }) do
    with {:ok, start_dt} <- parse_datetime(period_start),
         {:ok, end_dt} <- parse_datetime(period_end),
         {:ok, report} <- ReportOps.generate_financial_report(start_dt, end_dt, generated_by) do
      conn
      |> put_status(:created)
      |> json(%{
        status: "ok",
        message: "Financial report generated",
        report: format_report_response(report)
      })
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Genera análisis detallado de un sorteo específico.

  Parámetros:
  - draw_id: String - ID del sorteo a analizar
  - generated_by: String - ID del admin que genera

  Retorna:
  - 201 Created: Análisis generado exitosamente
  - 404 Not Found: Sorteo no existe
  - 500 Error: Error en servidor
  """
  def generate_draw_analysis(conn, %{"draw_id" => draw_id, "generated_by" => generated_by}) do
    case ReportOps.generate_draw_analysis(draw_id, generated_by) do
      {:ok, report} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "ok",
          message: "Draw analysis generated",
          report: format_report_response(report)
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Genera resumen de premios pagados en un período.

  Parámetros:
  - period_start: DateTime - fecha inicial del período
  - period_end: DateTime - fecha final del período
  - generated_by: String - ID del admin que genera

  Retorna:
  - 201 Created: Resumen generado exitosamente
  - 400 Bad Request: Validación fallida
  """
  def generate_prize_summary(conn, %{
    "period_start" => period_start,
    "period_end" => period_end,
    "generated_by" => generated_by
  }) do
    with {:ok, start_dt} <- parse_datetime(period_start),
         {:ok, end_dt} <- parse_datetime(period_end),
         {:ok, report} <- ReportOps.generate_prize_summary(start_dt, end_dt, generated_by) do
      conn
      |> put_status(:created)
      |> json(%{
        status: "ok",
        message: "Prize summary generated",
        report: format_report_response(report)
      })
    else
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene detalles de un reporte específico.

  Retorna:
  - 200 OK: Detalles del reporte
  - 404 Not Found: Reporte no existe
  """
  def get(conn, %{"report_id" => report_id}) do
    case ReportOps.get_report(report_id) do
      {:ok, report} ->
        json(conn, %{
          status: "ok",
          report: format_report_response(report)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista todos los reportes generados.

  Retorna lista ordenada por fecha descendente (más recientes primero).

  Retorna:
  - 200 OK: Lista de reportes
  - 500 Error: Error en servidor
  """
  def list(conn, _params) do
    case ReportOps.list_reports() do
      {:ok, reports} ->
        json(conn, %{
          status: "ok",
          reports: Enum.map(reports, &format_report_response/1),
          total: length(reports)
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista reportes por tipo.

  Tipos válidos: "financial", "draw_analysis", "player_stats", "prize_summary"

  Parámetros:
  - report_type: String - tipo de reporte

  Retorna:
  - 200 OK: Lista de reportes filtrada
  - 400 Bad Request: Tipo inválido
  """
  def list_by_type(conn, %{"report_type" => report_type}) do
    valid_types = ["financial", "draw_analysis", "player_stats", "prize_summary"]

    if report_type in valid_types do
      case ReportOps.list_reports_by_type(report_type) do
        {:ok, reports} ->
          json(conn, %{
            status: "ok",
            reports: Enum.map(reports, &format_report_response/1),
            total: length(reports),
            filter: report_type
          })

        {:error, reason} ->
          conn
          |> put_status(:internal_server_error)
          |> json(%{
            status: "error",
            message: reason
          })
      end
    else
      conn
      |> put_status(:bad_request)
      |> json(%{
        status: "error",
        message: "Invalid report type",
        valid_types: valid_types
      })
    end
  end

  # ============================================================================
  # FUNCIONES AUXILIARES
  # ============================================================================

  defp format_report_response(report) do
    %{
      id: report.id,
      title: report.title,
      report_type: report.report_type,
      period_start: report.period_start,
      period_end: report.period_end,
      generated_at: report.generated_at,
      generated_by: report.generated_by,
      data: report.data,
      summary: report.summary
    }
  end

  defp parse_datetime(datetime_string) when is_binary(datetime_string) do
    case DateTime.from_iso8601(datetime_string) do
      {:ok, dt, _offset} -> {:ok, dt}
      error -> {:error, "Invalid date format"}
    end
  end

  defp parse_datetime(_), do: {:error, "Date must be a string"}
end
