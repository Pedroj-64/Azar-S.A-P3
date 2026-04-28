defmodule AzarPlayerClient.Contexts.Purchases.Purchase do
  @moduledoc """
  Struct que representa una Compra de billete realizada por un jugador.

  Una compra puede ser:
  - Un billete completo de un sorteo
  - Una o más fracciones del billete

  Registra:
  - Qué se compró
  - Cuándo se compró
  - A cuánto se compró
  - Estado actual (activa, devuelta, premiada)
  """

  @enforce_keys [:id, :user_id, :draw_id, :purchase_type]
  defstruct [
    :id,                          # UUID único de la compra
    :user_id,                     # ID del jugador que compró
    :user_name,                   # Nombre del jugador
    :draw_id,                     # ID del sorteo
    :draw_name,                   # Nombre del sorteo
    :purchase_type,               # Tipo: "complete" (billete completo) o "fraction" (fracción)
    :ticket_number,               # Número del billete (001-999)
    :fraction_number,             # Número de fracción si es fraccionado (1 a N)
    :price,                       # Precio pagado
    :purchase_date,               # Fecha de compra
    :status,                      # Estado: "active", "returned", "won", "lost"
    :returned_date,               # Fecha de devolución (si aplica)
    :return_reason,               # Razón de devolución
    :refund_amount,               # Monto devuelto (si aplica)
    :prize_won,                   # Monto ganado (si aplica)
    :is_winner,                   # Booleano: ¿ganó algún premio?
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          user_name: String.t(),
          draw_id: String.t(),
          draw_name: String.t(),
          purchase_type: String.t(),
          ticket_number: String.t(),
          fraction_number: integer() | nil,
          price: number(),
          purchase_date: DateTime.t(),
          status: String.t(),
          returned_date: DateTime.t() | nil,
          return_reason: String.t() | nil,
          refund_amount: number() | nil,
          prize_won: number() | nil,
          is_winner: boolean(),
          remarks: String.t() | nil
        }

  @doc """
  Crea una nueva compra.

  Parámetros:
  - user_id: ID del jugador
  - draw_id: ID del sorteo
  - purchase_type: "complete" o "fraction"
  - ticket_number: número del billete
  - price: precio pagado
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || generate_id(),
      user_id: attrs[:user_id],
      user_name: attrs[:user_name],
      draw_id: attrs[:draw_id],
      draw_name: attrs[:draw_name],
      purchase_type: attrs[:purchase_type],
      ticket_number: attrs[:ticket_number],
      fraction_number: attrs[:fraction_number],
      price: attrs[:price],
      purchase_date: DateTime.utc_now(),
      status: "active",
      returned_date: nil,
      return_reason: nil,
      refund_amount: nil,
      prize_won: nil,
      is_winner: false,
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
