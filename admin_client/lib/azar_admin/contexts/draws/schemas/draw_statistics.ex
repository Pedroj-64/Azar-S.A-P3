defmodule AzarAdminClient.Contexts.Draws.Schemas.DrawStatistics do
  @moduledoc """
  Schema que contiene estadísticas de un sorteo.

  Usado para reportes y análisis financiero del sorteo.
  """

  @enforce_keys [:draw_id, :draw_name, :status]
  defstruct [
    :draw_id,
    :draw_name,
    :status,
    :total_revenue,               # Total de ingresos
    :tickets_sold,                # Billetes vendidos
    :tickets_available,           # Billetes disponibles
    :total_tickets,               # Total de billetes
    :estimated_payout,            # Pago estimado de premios
    :margin,                      # Ganancia neta
    :execution_date,              # Fecha de ejecución
    :winning_numbers_count        # Cantidad de números ganadores
  ]

  @type t :: %__MODULE__{
          draw_id: String.t(),
          draw_name: String.t(),
          status: String.t(),
          total_revenue: number(),
          tickets_sold: integer(),
          tickets_available: integer(),
          total_tickets: integer(),
          estimated_payout: number(),
          margin: number(),
          execution_date: DateTime.t() | nil,
          winning_numbers_count: integer()
        }

  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      draw_id: attrs[:draw_id],
      draw_name: attrs[:draw_name],
      status: attrs[:status],
      total_revenue: attrs[:total_revenue] || 0.0,
      tickets_sold: attrs[:tickets_sold] || 0,
      tickets_available: attrs[:tickets_available] || 0,
      total_tickets: attrs[:total_tickets] || 0,
      estimated_payout: attrs[:estimated_payout] || 0.0,
      margin: attrs[:margin] || 0.0,
      execution_date: attrs[:execution_date],
      winning_numbers_count: attrs[:winning_numbers_count] || 0
    }
  end
end
