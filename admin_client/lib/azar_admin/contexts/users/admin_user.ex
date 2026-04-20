defmodule AzarAdmin.Contexts.Users.AdminUser do
  @moduledoc """
  Struct que representa un Usuario Administrador en el sistema.

  Los administradores pueden:
  - Crear y gestionar sorteos
  - Crear y gestionar premios
  - Ver reportes y estadísticas
  - Gestionar usuarios
  """

  @enforce_keys [:id, :name, :email, :password_hash]
  defstruct [
    :id,                          # UUID único del administrador
    :name,                        # Nombre completo
    :email,                       # Email único
    :password_hash,               # Contraseña hasheada con bcrypt
    :role,                        # Rol: "admin", "supervisor"
    :status,                      # Estado: "active", "inactive", "suspended"
    :created_at,                  # Fecha de creación
    :last_login,                  # Fecha del último login
    :permissions,                 # Lista de permisos específicos
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          email: String.t(),
          password_hash: String.t(),
          role: String.t(),
          status: String.t(),
          created_at: DateTime.t(),
          last_login: DateTime.t() | nil,
          permissions: [String.t()],
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo usuario administrador.

  Parámetros:
  - name: nombre completo
  - email: email único
  - password_hash: contraseña ya hasheada
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || generate_id(),
      name: attrs[:name],
      email: attrs[:email],
      password_hash: attrs[:password_hash],
      role: attrs[:role] || "admin",
      status: "active",
      created_at: DateTime.utc_now(),
      last_login: nil,
      permissions: attrs[:permissions] || default_permissions(),
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end

  defp default_permissions do
    [
      "view_draws",
      "create_draws",
      "edit_draws",
      "delete_draws",
      "view_prizes",
      "create_prizes",
      "edit_prizes",
      "delete_prizes",
      "view_reports",
      "view_users"
    ]
  end
end
