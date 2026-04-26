defmodule AzarAdmin.Contexts.Users.AdminUser do
  @moduledoc """
  Struct representing an Administrator user in the system.

  Administrators can:
  - Create and manage draws
  - Create and manage prizes
  - View reports and statistics
  - Manage users
  """

  @enforce_keys [:id, :name, :email, :password_hash]
  defstruct [
    :id,                          # Unique administrator UUID
    :name,                        # Full name
    :email,                       # Unique email
    :password_hash,               # Password hashed with bcrypt
    :role,                        # Role: "admin", "supervisor"
    :status,                      # Status: "active", "inactive", "suspended"
    :created_at,                  # Creation timestamp
    :last_login,                  # Last login timestamp
    :permissions,                 # List of specific permissions
    :remarks                       # Remarks or notes
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
  Creates a new administrator user.

  Parameters:
  - name: full name
  - email: unique email
  - password_hash: already hashed password
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
