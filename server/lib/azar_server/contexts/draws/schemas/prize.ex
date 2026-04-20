defmodule AzarServer.Contexts.Draws.Schemas.Prize do
  @moduledoc """
  Schema que representa un Premio en un Sorteo.

  Un premio es una recompensa asociada a números específicos
  en un sorteo. Ejemplo: 100.000 al número 001, 50.000 al 002, etc.
  """

  @enforce_keys [:id, :draw_id, :name, :value]
  defstruct [
    :id,                          # UUID único del premio
    :draw_id,                     # Referencia al sorteo
    :name,                        # Nombre del premio (ej: "Premio Mayor")
    :value,                       # Monto del premio
    :associated_numbers,          # Lista de números ganadores
    :created_at,                  # Fecha de creación
    :awarded_to,                  # ID de usuario que recibió el premio (si aplica)
    :status,                      # Estado: "pending", "awarded", "cancelled"
    :description,                 # Descripción del premio
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          draw_id: String.t(),
          name: String.t(),
          value: number(),
          associated_numbers: [String.t()],
          created_at: DateTime.t(),
          awarded_to: String.t() | nil,
          status: String.t(),
          description: String.t() | nil,
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo premio.

  Parámetros:
  - draw_id: ID del sorteo al que pertenece
  - name: Nombre del premio
  - value: Monto a premiar
  - associated_numbers: Lista de números que ganan este premio
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || generate_id(),
      draw_id: attrs[:draw_id],
      name: attrs[:name],
      value: attrs[:value],
      associated_numbers: attrs[:associated_numbers] || [],
      created_at: DateTime.utc_now(),
      awarded_to: nil,
      status: "pending",
      description: attrs[:description],
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
