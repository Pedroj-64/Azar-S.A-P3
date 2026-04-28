defmodule AzarAdminClient.Contexts.Draws.Schemas.Prize do
  @moduledoc """
  Schema que representa un Premio en un Sorteo.

  Los premios son las recompensas asociadas a números ganadores.
  """

  @enforce_keys [:id, :draw_id, :prize_tier]
  defstruct [
    :id,
    :draw_id,
    :prize_tier,                  # "first", "second", "third", etc
    :amount,                      # Monto del premio
    :winning_number,              # Número ganador asociado
    :winners_count,               # Cantidad de ganadores
    :claimed,                     # Si fue reclamado
    :created_at
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          draw_id: String.t(),
          prize_tier: String.t(),
          amount: number(),
          winning_number: integer() | nil,
          winners_count: integer(),
          claimed: boolean(),
          created_at: DateTime.t()
        }

  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || UUID.uuid4(),
      draw_id: attrs[:draw_id],
      prize_tier: attrs[:prize_tier],
      amount: attrs[:amount],
      winning_number: attrs[:winning_number],
      winners_count: attrs[:winners_count] || 0,
      claimed: attrs[:claimed] || false,
      created_at: attrs[:created_at] || DateTime.utc_now()
    }
  end
end
