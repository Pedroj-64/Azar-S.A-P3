defmodule AzarServer.Contexts.Draws.Draw do
  @moduledoc """
  Struct que representa un Sorteo en el sistema.

  Un sorteo es la entidad principal que contiene:
  - Información general (nombre, fecha, etc)
  - Billetes disponibles (completos y fracciones)
  - Premios asociados
  - Estado actual del sorteo
  """

  @enforce_keys [:id, :name, :draw_date, :full_ticket_value, :fractions_count, :total_tickets]
  defstruct [
    :id,                          # UUID único del sorteo
    :name,                        # Nombre del sorteo (ej: "Sorteo Navidad 2026")
    :draw_date,                   # Fecha de ejecución DateTime
    :full_ticket_value,           # Precio del billete completo (número)
    :fractions_count,             # Cantidad de fracciones por billete
    :total_tickets,               # Cantidad total de billetes disponibles
    :status,                      # Estado: "open", "executed", "cancelled"
    :available_tickets,           # Billetes disponibles para compra
    :created_at,                  # Fecha de creación
    :executed_at,                 # Fecha de ejecución (si aplica)
    :winning_numbers,             # Lista de números ganadores después de ejecutarse
    :remarks                       # Observaciones adicionales
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          draw_date: DateTime.t(),
          full_ticket_value: number(),
          fractions_count: integer(),
          total_tickets: integer(),
          status: String.t(),
          available_tickets: integer(),
          created_at: DateTime.t(),
          executed_at: DateTime.t() | nil,
          winning_numbers: [integer()] | nil,
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo sorteo con los parámetros básicos.

  Retorna un struct Sorteo con valores por defecto.
  """
  @spec new(map()) :: t()
  def new(attrs) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: attrs[:id] || generate_id(),
      name: attrs[:name],
      draw_date: attrs[:draw_date],
      full_ticket_value: attrs[:full_ticket_value],
      fractions_count: attrs[:fractions_count],
      total_tickets: attrs[:total_tickets],
      status: "open",
      available_tickets: attrs[:total_tickets],
      created_at: now,
      executed_at: nil,
      winning_numbers: nil,
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
