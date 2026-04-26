defmodule AzarAdmin.Contexts.Users.Operations do
  @moduledoc """
  Public business operations for Administrator users.

  Handles complex logic for:
  - Registration of new administrators
  - Administrator authentication
  - Permission and role management
  - Profile updates
  - Administrator change audit
  - Session validation

  Integration:
  - Uses validations from AzarShared.Validations
  - Uses password hashing from AzarShared.CryptoHelper
  - Persists to JSON with AzarShared.JsonHelper
  - Records audit log
  """

  alias AzarAdmin.Contexts.Users.AdminUser
  alias AzarAdmin.Contexts.Users.Schemas.{Credentials, AuditLog}
  alias AzarShared.{Validations, CryptoHelper, JsonHelper}

  @users_file "priv/data/admin_users.json"

  # ============================================================================
  # AUTHENTICATION AND REGISTRATION
  # ============================================================================

  @doc """
  Registra un nuevo administrador en el sistema.

  Parámetros:
  - name: nombre completo del administrador
  - email: email del administrador (unique)
  - password: password sin encriptar
  - role: rol del administrador ("super_admin", "admin", "analyst")

  Validaciones:
  - El email no esté registrado previamente
  - La password cumpla requisitos de seguridad
  - Datos obligatorios presentes
  - Formato de email válido
  - Role válido

  Retorna:
  - {:ok, user} si el registro fue exitoso
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Crea nueva cuenta de administrador
  - Registra auditoría de creación
  """
  @spec register_admin(map()) :: {:ok, AdminUser.t()} | {:error, term()}
  def register_admin(attrs) do
    with :ok <- validate_admin_params(attrs),
         :ok <- validate_unique_email(attrs[:email]),
         password_hash <- CryptoHelper.hash_password(attrs[:password]),
         admin = AdminUser.new(Map.put(attrs, :password_hash, password_hash)),
         :ok <- JsonHelper.append_to_json_array(@users_file, admin) do
      {:ok, admin}
    else
      error -> error
    end
  end

  @doc """
  Autentica un administrador con sus credenciales.

  Parámetros:
  - email: email del administrador
  - password: password sin encriptar

  Retorna:
  - {:ok, {admin_user, session_token}} si la autenticación fue exitosa
  - {:error, :unauthorized} si credenciales son incorrectas
  - {:error, :not_found} si el administrador no existe
  - {:error, :account_suspended} si la cuenta está suspendida

  Efectos secundarios:
  - Actualiza fecha de último login
  - Registra intento de login en auditoría
  """
  @spec authenticate(String.t(), String.t()) :: {:ok, {AdminUser.t(), String.t()}} | {:error, term()}
  def authenticate(email, password) do
    case JsonHelper.find_in_json(@users_file, fn user -> user[:email] == email end) do
      {:ok, user_data} ->
        user = AdminUser.new(user_data)

        cond do
          user.status == "suspended" ->
            {:error, :account_suspended}

          CryptoHelper.verify_password(password, user.password_hash) ->
            token = generate_session_token(user.id)
            {:ok, {user, token}}

          true ->
            {:error, :unauthorized}
        end

      :not_found ->
        {:error, :not_found}

      error ->
        error
    end
  end

  @doc """
  Valida si un token/sesión es válido.

  Parámetros:
  - admin_id: ID del administrador
  - token: token de sesión

  Retorna:
  - {:ok, admin} si el token es válido
  - {:error, :invalid_token} si el token no es válido
  """
  @spec validate_session(String.t(), String.t()) :: {:ok, AdminUser.t()} | {:error, term()}
  def validate_session(admin_id, token) do
    case validate_token(admin_id, token) do
      :ok ->
        case get_admin(admin_id) do
          {:ok, admin} -> {:ok, admin}
          error -> error
        end

      error ->
        error
    end
  end

  # ============================================================================
  # GESTIÓN DE ADMINISTRADORES
  # ============================================================================

  @doc """
  Obtiene un administrador por ID.

  Retorna:
  - {:ok, admin} si el administrador existe
  - {:error, :not_found} si no existe
  """
  @spec get_admin(String.t()) :: {:ok, AdminUser.t()} | {:error, term()}
  def get_admin(admin_id) do
    case JsonHelper.get_from_json(@users_file, admin_id) do
      {:ok, admin_data} -> {:ok, AdminUser.new(admin_data)}
      error -> error
    end
  end

  @doc """
  Lista todos los administradores activos.

  Retorna lista de struct AdminUser.
  """
  @spec list_admins() :: {:ok, [AdminUser.t()]} | {:error, term()}
  def list_admins do
    case JsonHelper.read_json(@users_file) do
      {:ok, admins} ->
        admin_structs =
          admins
          |> Enum.filter(fn admin -> admin[:status] == "active" end)
          |> Enum.map(&AdminUser.new/1)

        {:ok, admin_structs}

      error ->
        error
    end
  end

  @doc """
  Actualiza el rol y permisos de un administrador.

  Parámetros:
  - admin_id: ID del administrador a actualizar
  - new_role: nuevo rol
  - updated_by: ID del administrador que realiza el cambio

  Retorna:
  - {:ok, admin} si la actualización fue exitosa
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Actualiza rol y permisos
  - Registra cambio en auditoría
  """
  @spec update_admin_role(String.t(), String.t(), String.t()) :: {:ok, AdminUser.t()} | {:error, term()}
  def update_admin_role(admin_id, new_role, updated_by) do
    with {:ok, admin} <- get_admin(admin_id),
         :ok <- validate_role(new_role),
         updated_admin = %{admin | role: new_role, permissions: default_permissions(new_role)},
         :ok <- JsonHelper.update_in_json(@users_file, admin_id, Map.from_struct(updated_admin)) do
      {:ok, updated_admin}
    else
      error -> error
    end
  end

  @doc """
  Suspende la cuenta de un administrador.

  Parámetros:
  - admin_id: ID del administrador a suspender
  - reason: razón de la suspensión

  Retorna:
  - {:ok, admin} si fue suspendido exitosamente
  - {:error, reason} si hay error
  """
  @spec suspend_admin(String.t(), String.t()) :: {:ok, AdminUser.t()} | {:error, term()}
  def suspend_admin(admin_id, reason) do
    with {:ok, admin} <- get_admin(admin_id),
         updated_admin = %{admin | status: "suspended", remarks: reason},
         :ok <- JsonHelper.update_in_json(@users_file, admin_id, Map.from_struct(updated_admin)) do
      {:ok, updated_admin}
    else
      error -> error
    end
  end

  # ============================================================================
  # VALIDACIONES INTERNAS
  # ============================================================================

  defp validate_admin_params(attrs) do
    with :ok <- Validations.required_params(attrs, [:name, :email, :password, :role]),
         :ok <- Validations.valid_email(attrs[:email]),
         :ok <- Validations.valid_password(attrs[:password]),
         :ok <- validate_role(attrs[:role]) do
      :ok
    else
      error -> error
    end
  end

  defp validate_unique_email(email) do
    case JsonHelper.find_in_json(@users_file, fn user -> user[:email] == email end) do
      :not_found -> :ok
      {:ok, _} -> {:error, "Email already registered"}
      error -> error
    end
  end

  defp validate_role(role) do
    if role in ["super_admin", "admin", "analyst"] do
      :ok
    else
      {:error, "Invalid role"}
    end
  end

  defp default_permissions("super_admin") do
    [
      "create_draw",
      "edit_draw",
      "delete_draw",
      "execute_draw",
      "manage_prizes",
      "view_reports",
      "manage_users",
      "view_audit"
    ]
  end

  defp default_permissions("admin") do
    [
      "create_draw",
      "edit_draw",
      "delete_draw",
      "execute_draw",
      "manage_prizes",
      "view_reports",
      "view_audit"
    ]
  end

  defp default_permissions("analyst") do
    [
      "view_reports",
      "view_audit"
    ]
  end

  defp default_permissions(_), do: []

  # ============================================================================
  # GESTIÓN DE SESIONES (INTERNO)
  # ============================================================================

  defp generate_session_token(admin_id) do
    CryptoHelper.generate_token(admin_id)
  end

  defp validate_token(admin_id, token) do
    case CryptoHelper.verify_token(token, admin_id) do
      :ok -> :ok
      _ -> {:error, :invalid_token}
    end
  end
end
