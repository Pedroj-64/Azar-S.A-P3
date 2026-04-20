defmodule AzarAdmin.Contexts.Reports.IncomeReport do
  @moduledoc """
  Struct que representa un Reporte de Ingresos.

  Contiene:
  - Ingresos totales por sorteo
  - Premios pagados
  - Ganancia neta
  - Estadísticas de ventas
  """

  @enforce_keys [:id, :draw_id, :total_revenue]
  defstruct [
    :id,                          # UUID único del reporte
    :draw_id,                     # Referencia al sorteo
    :total_revenue,               # Ingresos totales (billetes vendidos)
    :total_prizes,                # Premios pagados
    :net_profit,                  # Ganancia neta (revenue - prizes)
    :tickets_sold,                # Cantidad de billetes vendidos
    :complete_tickets_sold,       # Billetes completos vendidos
    :fractions_sold,              # Fracciones vendidas
    :tickets_returned,            # Billetes devueltos
    :average_price,               # Precio promedio
    :generated_at,                # Fecha de generación del reporte
    :period_start,                # Inicio del período
    :period_end,                  # Fin del período
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          draw_id: String.t(),
          total_revenue: number(),
          total_prizes: number(),
          net_profit: number(),
          tickets_sold: integer(),
          complete_tickets_sold: integer(),
          fractions_sold: integer(),
          tickets_returned: integer(),
          average_price: number(),
          generated_at: DateTime.t(),
          period_start: DateTime.t(),
          period_end: DateTime.t(),
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo reporte de ingresos.

  Parámetros:
  - draw_id: ID del sorteo a reportar
  - total_revenue: ingresos totales
  - total_prizes: premios pagados
  """
  @spec new(map()) :: t()
  def new(attrs) do
    total_revenue = attrs[:total_revenue] || 0
    total_prizes = attrs[:total_prizes] || 0

    %__MODULE__{
      id: attrs[:id] || generate_id(),
      draw_id: attrs[:draw_id],
      total_revenue: total_revenue,
      total_prizes: total_prizes,
      net_profit: total_revenue - total_prizes,
      tickets_sold: attrs[:tickets_sold] || 0,
      complete_tickets_sold: attrs[:complete_tickets_sold] || 0,
      fractions_sold: attrs[:fractions_sold] || 0,
      tickets_returned: attrs[:tickets_returned] || 0,
      average_price: calculate_average_price(total_revenue, attrs[:tickets_sold] || 1),
      generated_at: DateTime.utc_now(),
      period_start: attrs[:period_start],
      period_end: attrs[:period_end],
      remarks: attrs[:remarks]
    }
  end

  defp calculate_average_price(revenue, tickets) when tickets > 0 do
    Float.round(revenue / tickets, 2)
  end
  defp calculate_average_price(_revenue, _tickets), do: 0.0

  defp generate_id do
    UUID.uuid4()
  end
end
