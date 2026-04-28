defmodule AzarPlayerClient.Contexts.Purchases.Schemas.Transaction do
  @moduledoc """
  Struct que representa una Transacción asociada a una compra.

  Las transacciones registran movimientos de dinero:
  - Cobro por compra
  - Reembolso por devolución
  - Pago de premio ganado
  """

  @enforce_keys [:id, :user_id, :amount, :transaction_type]
  defstruct [
    :id,                          # UUID único de la transacción
    :user_id,                     # ID del jugador
    :purchase_id,                 # ID de compra relacionada (si aplica)
    :amount,                      # Monto de la transacción
    :transaction_type,            # Tipo: "debit" (compra), "credit" (reembolso/premio)
    :description,                 # Descripción de la transacción
    :status,                      # Estado: "completed", "pending", "failed"
    :created_at,                  # Fecha de creación
    :reference_id,                # ID de referencia externa
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          purchase_id: String.t() | nil,
          amount: number(),
          transaction_type: String.t(),
          description: String.t(),
          status: String.t(),
          created_at: DateTime.t(),
          reference_id: String.t() | nil,
          remarks: String.t() | nil
        }

  @doc """
  Crea una nueva transacción.
  """
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || UUID.uuid4(),
      user_id: attrs[:user_id],
      purchase_id: attrs[:purchase_id],
      amount: attrs[:amount],
      transaction_type: attrs[:transaction_type],
      description: attrs[:description],
      status: attrs[:status] || "completed",
      created_at: DateTime.utc_now(),
      reference_id: attrs[:reference_id],
      remarks: attrs[:remarks]
    }
  end
end
