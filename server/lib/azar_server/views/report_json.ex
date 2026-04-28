defmodule AzarServer.Views.ReportJSON do
  @moduledoc """
  JSON view para respuestas de Reportes.

  Proporciona funciones para formatear datos de reportes
  en respuestas JSON consistentes.
  """

  def income(%{report: report}) do
    %{
      status: "ok",
      data: report_data(report)
    }
  end

  def balance(%{report: report}) do
    %{
      status: "ok",
      data: report_data(report)
    }
  end

  def winners(%{report: report}) do
    %{
      status: "ok",
      data: report_data(report)
    }
  end

  defp report_data(report) do
    %{
      id: report.id,
      report_type: report.report_type,
      period_start: report.period_start,
      period_end: report.period_end,
      generated_by: report.generated_by,
      total_income: report.total_income,
      total_prizes_paid: report.total_prizes_paid,
      total_expenses: report.total_expenses,
      net_margin: report.net_margin,
      generated_at: report.generated_at
    }
  end
end
