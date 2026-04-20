defmodule AzarServer.Contexts.Draws.Schemas.Ticket do
  @moduledoc """
  Schema que representa un Billete en un Sorteo.

  Un billete puede ser:
  - Completo: un billete entero con número único
  - Fraccionado: una parte de un billete (1/N donde N = fractions_count)
  """

  @enforce_keys [:id, :number, :draw_id, :ticket_type, :owner]
  defstruct [
    :id,                          # UUID único del billete
    :number,                      # Número del billete (001-999)
    :draw_id,                     # Referencia al sorteo
    :ticket_type,                 # "complete" o "fraction"
    :fraction_number,             # Número de fracción si aplica (1 a fractions_count)
    :owner,                       # ID del usuario propietario
    :owner_name,                  # Nombre del propietario
    :purchase_date,               # Fecha de compra
    :status,                      # Estado: "active", "returned", "winner", "loser"
    :purchase_price,              # Precio pagado
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          number: String.t(),
          draw_id: String.t(),
          ticket_type: String.t(),
          fraction_number: integer() | nil,
          owner: String.t(),
          owner_name: String.t(),
          purchase_date: DateTime.t(),
          status: String.t(),
          purchase_price: number(),
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo billete.

  Los tipos soportados son:
  - "complete": billete completo
  - "fraction": una fracción del billete
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || generate_id(),
      number: attrs[:number],
      draw_id: attrs[:draw_id],
      ticket_type: attrs[:ticket_type],
      fraction_number: attrs[:fraction_number],
      owner: attrs[:owner],
      owner_name: attrs[:owner_name],
      purchase_date: DateTime.utc_now(),
      status: "active",
      purchase_price: attrs[:purchase_price],
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
