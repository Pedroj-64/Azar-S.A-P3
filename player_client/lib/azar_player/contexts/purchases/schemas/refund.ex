defmodule AzarPlayer.Contexts.Purchases.Schemas.Refund do
  @moduledoc """
  Struct que representa un Reembolso de compra.

  Cuando un jugador devuelve una compra, se genera un registro de reembolso
  que documenta qué se devolvió, cuánto, y por qué.
  """

  @enforce_keys [:id, :purchase_id, :refund_amount]
  defstruct [
    :id,                          # UUID único del reembolso
    :purchase_id,                 # ID de la compra que se devuelve
    :refund_amount,               # Monto devuelto
    :reason,                      # Razón de la devolución
    :status,                      # Estado: "processed", "pending", "denied"
    :processed_date,              # Fecha en que se procesó
    :user_id,                     # ID del jugador
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          purchase_id: String.t(),
          refund_amount: number(),
          reason: String.t(),
          status: String.t(),
          processed_date: DateTime.t(),
          user_id: String.t(),
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo reembolso.
  """
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || UUID.uuid4(),
      purchase_id: attrs[:purchase_id],
      refund_amount: attrs[:refund_amount],
      reason: attrs[:reason],
      status: attrs[:status] || "processed",
      processed_date: DateTime.utc_now(),
      user_id: attrs[:user_id],
      remarks: attrs[:remarks]
    }
  end
end
