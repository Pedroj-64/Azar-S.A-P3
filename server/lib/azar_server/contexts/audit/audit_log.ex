defmodule AzarServer.Contexts.Audit.AuditLog do
  @moduledoc """
  Schema que representa un Registro de Auditoría.

  Registra todas las operaciones importantes en el sistema:
  - Creación/eliminación de sorteos
  - Compras/devoluciones de billetes
  - Ejecución de sorteos
  - Acciones administrativas

  Permite rastrear quién hizo qué y cuándo.
  """

  @enforce_keys [:id, :action, :entity_type, :user_id]
  defstruct [
    :id,                          # UUID único del registro
    :action,                      # Tipo de acción: "create", "update", "delete", "buy", "return", "execute"
    :entity_type,                 # Tipo de entidad: "draw", "ticket", "prize", "user"
    :entity_id,                   # ID de la entidad afectada
    :user_id,                     # ID del usuario que realizó la acción
    :user_name,                   # Nombre del usuario
    :user_role,                   # Rol del usuario: "admin", "player", "system"
    :timestamp,                   # Fecha y hora de la acción
    :old_value,                   # Valor anterior (para updates)
    :new_value,                   # Valor nuevo (para updates)
    :description,                 # Descripción legible de la acción
    :ip_address,                  # IP desde donde se realizó la acción
    :status,                      # Estado de la acción: "success", "failed"
    :error_message,               # Mensaje de error si aplica
    :remarks                       # Observaciones adicionales
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          action: String.t(),
          entity_type: String.t(),
          entity_id: String.t() | nil,
          user_id: String.t(),
          user_name: String.t(),
          user_role: String.t(),
          timestamp: DateTime.t(),
          old_value: any() | nil,
          new_value: any() | nil,
          description: String.t(),
          ip_address: String.t() | nil,
          status: String.t(),
          error_message: String.t() | nil,
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo registro de auditoría.

  Parámetros:
  - action: acción realizada
  - entity_type: tipo de entidad afectada
  - user_id: usuario que realizó la acción
  - description: descripción de lo que sucedió
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || generate_id(),
      action: attrs[:action],
      entity_type: attrs[:entity_type],
      entity_id: attrs[:entity_id],
      user_id: attrs[:user_id],
      user_name: attrs[:user_name],
      user_role: attrs[:user_role] || "system",
      timestamp: DateTime.utc_now(),
      old_value: attrs[:old_value],
      new_value: attrs[:new_value],
      description: attrs[:description],
      ip_address: attrs[:ip_address],
      status: attrs[:status] || "success",
      error_message: attrs[:error_message],
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
