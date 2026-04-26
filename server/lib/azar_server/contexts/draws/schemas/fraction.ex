defmodule AzarServer.Contexts.Draws.Schemas.Fraction do
  @moduledoc """
  Schema que representa una Fracción de un Billete en un Sorteo.

  Una fracción es una parte de un billete completo (1/N donde N = fractions_count).
  Permite que múltiples usuarios posean partes del mismo billete.

  Ejemplo: Un billete completo puede dividirse en 10 fracciones,
  permitiendo que 10 usuarios compren 1 fracción cada uno.
  """

  @enforce_keys [:id, :ticket_id, :draw_id, :ticket_number, :fraction_number, :owner]
  defstruct [
    :id,                          # UUID único de la fracción
    :ticket_id,                   # Referencia al billete completo
    :draw_id,                     # Referencia al sorteo
    :ticket_number,               # Número del billete (001-999)
    :fraction_number,             # Posición de esta fracción (1 a fractions_count)
    :total_fractions,             # Cantidad total de fracciones del billete
    :owner,                       # ID del usuario propietario
    :owner_name,                  # Nombre del propietario
    :purchase_date,               # Fecha de compra
    :status,                      # Estado: "active", "returned", "winner", "loser"
    :purchase_price,              # Precio pagado por la fracción
    :fraction_price,              # Precio unitario de la fracción
    :created_at,                  # Fecha de creación
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          ticket_id: String.t(),
          draw_id: String.t(),
          ticket_number: String.t(),
          fraction_number: integer(),
          total_fractions: integer(),
          owner: String.t(),
          owner_name: String.t(),
          purchase_date: DateTime.t(),
          status: String.t(),
          purchase_price: number(),
          fraction_price: number(),
          created_at: DateTime.t(),
          remarks: String.t() | nil
        }

  @doc """
  Crea una nueva fracción con validación de datos básicos.

  Parámetros requeridos:
  - ticket_id: UUID del billete al que pertenece
  - draw_id: UUID del sorteo
  - ticket_number: Número del billete (001-999)
  - fraction_number: Número de la fracción (1 a total_fractions)
  - total_fractions: Cantidad total de fracciones del billete
  - owner: ID del usuario propietario
  - owner_name: Nombre del propietario
  - fraction_price: Precio de la fracción
  """
  @spec new(map()) :: t()
  def new(attrs) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: attrs[:id] || generate_id(),
      ticket_id: attrs[:ticket_id],
      draw_id: attrs[:draw_id],
      ticket_number: attrs[:ticket_number],
      fraction_number: attrs[:fraction_number],
      total_fractions: attrs[:total_fractions],
      owner: attrs[:owner],
      owner_name: attrs[:owner_name],
      purchase_date: now,
      status: "active",
      purchase_price: attrs[:purchase_price] || attrs[:fraction_price],
      fraction_price: attrs[:fraction_price],
      created_at: now,
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
