defmodule AzarAdmin.Contexts.Draws.AdminDraw do
  @moduledoc """
  Struct que representa un Sorteo desde la perspectiva del Administrador.

  Un sorteo es la entidad principal que contiene:
  - Información general (nombre, fecha, etc)
  - Billetes disponibles (completos y fracciones)
  - Premios asociados
  - Estado actual del sorteo
  - Estadísticas financieras

  Los administradores pueden:
  - Crear sorteos
  - Editar configuración
  - Ejecutar sorteos y seleccionar ganadores
  - Ver reportes del sorteo
  """

  @enforce_keys [:id, :name, :draw_date, :full_ticket_value, :fractions_count, :total_tickets]
  defstruct [
    :id,                          # UUID unique del sorteo
    :name,                        # Nombre del sorteo (ej: "Sorteo Navidad 2026")
    :draw_date,                   # Fecha de ejecución DateTime
    :full_ticket_value,           # Precio del billete completo (número)
    :fractions_count,             # Cantidad de fracciones por billete
    :total_tickets,               # Cantidad total de billetes disponibles
    :status,                      # Estado: "open", "executed", "cancelled"
    :available_tickets,           # Billetes disponibles para compra
    :sold_tickets,                # Billetes vendidos
    :total_revenue,               # Ingresos totales
    :created_at,                  # Fecha de creación
    :created_by,                  # ID del admin que creó
    :executed_at,                 # Fecha de ejecución (si aplica)
    :executed_by,                 # ID del admin que ejecutó
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
          sold_tickets: integer(),
          total_revenue: number(),
          created_at: DateTime.t(),
          created_by: String.t(),
          executed_at: DateTime.t() | nil,
          executed_by: String.t() | nil,
          winning_numbers: [integer()] | nil,
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo sorteo con los parameters básicos.

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
      sold_tickets: 0,
      total_revenue: 0.0,
      created_at: now,
      created_by: attrs[:created_by],
      executed_at: nil,
      executed_by: nil,
      winning_numbers: nil,
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
