defmodule AzarPlayer.Contexts.Users.Schemas.BalanceRecord do
  @moduledoc """
  Struct que representa un Registro de Movimiento de Saldo.

  Cada transacción de dinero (compra, reembolso, premio) genera un registro
  para mantener un historial auditable del saldo del jugador.
  """

  @enforce_keys [:id, :user_id, :amount, :transaction_type]
  defstruct [
    :id,                          # UUID único del registro
    :user_id,                     # ID del jugador
    :amount,                      # Monto del movimiento
    :transaction_type,            # Tipo: :debit (salida) o :credit (entrada)
    :description,                 # Descripción del movimiento
    :reference_id,                # ID de referencia (compra, reembolso, etc)
    :balance_before,              # Saldo anterior
    :balance_after,               # Saldo después del movimiento
    :created_at,                  # Fecha/hora del movimiento
    :notes                         # Notas adicionales
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          amount: number(),
          transaction_type: atom() | String.t(),
          description: String.t(),
          reference_id: String.t() | nil,
          balance_before: number(),
          balance_after: number(),
          created_at: DateTime.t(),
          notes: String.t() | nil
        }

  @doc """
  Crea un nuevo registro de movimiento de saldo.
  """
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || UUID.uuid4(),
      user_id: attrs[:user_id],
      amount: attrs[:amount],
      transaction_type: attrs[:transaction_type],
      description: attrs[:description],
      reference_id: attrs[:reference_id],
      balance_before: attrs[:balance_before] || 0.0,
      balance_after: attrs[:balance_after] || 0.0,
      created_at: DateTime.utc_now(),
      notes: attrs[:notes]
    }
  end

  @doc """
  Calcula la diferencia de saldo.
  """
  def balance_difference(%__MODULE__{} = record) do
    record.balance_after - record.balance_before
  end
end
