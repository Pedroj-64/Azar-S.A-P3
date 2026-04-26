defmodule AzarAdmin.Contexts.Reports.Schemas.FinancialSummary do
  @moduledoc """
  Schema para resumen financiero.
  """

  defstruct [
    :total_draws,
    :total_revenue,
    :total_premios,
    :total_margin,
    :draws_executed,
    :draws_open,
    :draws_cancelled
  ]

  @type t :: %__MODULE__{
          total_draws: integer(),
          total_revenue: number(),
          total_premios: number(),
          total_margin: number(),
          draws_executed: integer(),
          draws_open: integer(),
          draws_cancelled: integer()
        }

  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      total_draws: attrs[:total_draws] || 0,
      total_revenue: attrs[:total_revenue] || 0.0,
      total_premios: attrs[:total_premios] || 0.0,
      total_margin: attrs[:total_margin] || 0.0,
      draws_executed: attrs[:draws_executed] || 0,
      draws_open: attrs[:draws_open] || 0,
      draws_cancelled: attrs[:draws_cancelled] || 0
    }
  end
end
