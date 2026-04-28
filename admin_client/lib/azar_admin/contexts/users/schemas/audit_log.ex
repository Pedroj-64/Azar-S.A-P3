defmodule AzarAdminClient.Contexts.Users.Schemas.AuditLog do
  @moduledoc """
  Schema que registra auditoría de acciones de administradores.

  Rastrea qué hizo cada administrador y cuándo.
  """

  @enforce_keys [:id, :admin_id, :action, :resource, :timestamp]
  defstruct [
    :id,
    :admin_id,
    :admin_name,
    :action,                      # "create", "update", "delete", "login", "logout"
    :resource,                    # "draw", "prize", "report", etc.
    :resource_id,                 # ID del recurso afectado
    :details,                     # Detalles del cambio
    :timestamp,                   # Cuándo ocurrió
    :ip_address                   # De dónde se realizó
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          admin_id: String.t(),
          admin_name: String.t() | nil,
          action: String.t(),
          resource: String.t(),
          resource_id: String.t() | nil,
          details: String.t() | nil,
          timestamp: DateTime.t(),
          ip_address: String.t() | nil
        }

  @doc """
  Crea un nuevo registro de auditoría.
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || UUID.uuid4(),
      admin_id: attrs[:admin_id],
      admin_name: attrs[:admin_name],
      action: attrs[:action],
      resource: attrs[:resource],
      resource_id: attrs[:resource_id],
      details: attrs[:details],
      timestamp: attrs[:timestamp] || DateTime.utc_now(),
      ip_address: attrs[:ip_address]
    }
  end
end
