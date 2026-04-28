defmodule AzarAdminClient.Contexts.Reports.Schemas.DrawAnalysis do
  @moduledoc """
  Schema para análisis detallado de un sorteo.
  """

  defstruct [
    :draw_id,
    :draw_name,
    :status,
    :total_revenue,
    :tickets_sold,
    :total_tickets,
    :estimated_payout,
    :margin,
    :winning_numbers_count
  ]

  @type t :: %__MODULE__{
          draw_id: String.t(),
          draw_name: String.t(),
          status: String.t(),
          total_revenue: number(),
          tickets_sold: integer(),
          total_tickets: integer(),
          estimated_payout: number(),
          margin: number(),
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
      total_tickets: attrs[:total_tickets] || 0,
      estimated_payout: attrs[:estimated_payout] || 0.0,
      margin: attrs[:margin] || 0.0,
      winning_numbers_count: attrs[:winning_numbers_count] || 0
    }
  end
end
