defmodule AzarAdminClient.Contexts.Reports.AdminReport do
  @moduledoc """
  Struct que representa un Reporte de análisis del sistema.

  Los reportes incluyen:
  - Estadísticas financieras globales
  - Análisis por sorteo
  - Análisis de ganancias y pérdidas
  - Estadísticas de jugadores
  - Información de premios pagados
  """

  @enforce_keys [:id, :title, :report_type, :generated_at]
  defstruct [
    :id,
    :title,
    :report_type,                 # "financial", "draw_analysis", "player_stats", "prize_summary"
    :period_start,                # Inicio del período
    :period_end,                  # Fin del período
    :generated_at,                # Cuándo se generó
    :generated_by,                # Admin que generó
    :data,                        # Datos del reporte (map)
    :summary                      # Resumen ejecutivo
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          title: String.t(),
          report_type: String.t(),
          period_start: DateTime.t() | nil,
          period_end: DateTime.t() | nil,
          generated_at: DateTime.t(),
          generated_by: String.t() | nil,
          data: map() | nil,
          summary: String.t() | nil
        }

  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || UUID.uuid4(),
      title: attrs[:title],
      report_type: attrs[:report_type],
      period_start: attrs[:period_start],
      period_end: attrs[:period_end],
      generated_at: attrs[:generated_at] || DateTime.utc_now(),
      generated_by: attrs[:generated_by],
      data: attrs[:data],
      summary: attrs[:summary]
    }
  end
end
