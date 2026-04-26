defmodule AzarAdmin.Controllers.UserController do
  @moduledoc """
  Controller para gestión de administradores.

  Proporciona endpoints para:
  - Registro de nuevos administradores
  - Autenticación (login)
  - Validación de sesión
  - Gestión de roles y permisos
  - Suspender administradores
  - Listar administradores
  """

  use Phoenix.Controller

  alias AzarAdmin.Contexts.Users.Operations, as: UserOps
  alias AzarShared.Errors

  @doc """
  Registra un nuevo administrador en el sistema.

  Parámetros esperados:
  - name: String - nombre completo
  - email: String - email unique
  - password: String - password (mínimo 8 caracteres)
  - role: String - rol ("super_admin", "admin", "analyst")

  Retorna:
  - 201 Created: {:ok, admin} - Admin creado exitosamente
  - 400 Bad Request: {:error, reasons} - Validación fallida
  - 409 Conflict: {:error, message} - Email ya registrado
  """
  def register(conn, %{"user" => user_params}) do
    case UserOps.register_admin(user_params) do
      {:ok, admin} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "ok",
          message: "Administrator registered successfully",
          user: format_admin_response(admin)
        })

      {:error, %{validation: reasons}} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: "Validation failed",
          errors: reasons
        })

      {:error, reason} ->
        conn
        |> put_status(:conflict)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Autentica un administrador (login).

  Parámetros esperados:
  - email: String
  - password: String

  Retorna:
  - 200 OK: {:ok, {admin, token}} - Login exitoso
  - 401 Unauthorized: {:error, message} - Credenciales incorrectas
  - 404 Not Found: {:error, message} - Admin no existe
  - 423 Locked: {:error, message} - Cuenta suspendida
  """
  def authenticate(conn, %{"email" => email, "password" => password}) do
    case UserOps.authenticate(email, password) do
      {:ok, {admin, session_token}} ->
        conn
        |> put_resp_cookie("admin_auth_token", session_token, http_only: true)
        |> json(%{
          status: "ok",
          message: "Authentication successful",
          user: format_admin_response(admin),
          token: session_token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: "Invalid email or password"
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: "Administrator not found"
        })

      {:error, :account_suspended} ->
        conn
        |> put_status(:locked)
        |> json(%{
          status: "error",
          message: "Account is suspended"
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Valida si una sesión es válida.

  Requiere header:
  - Authorization: "Bearer <token>"

  Retorna:
  - 200 OK: {:ok, admin} - Sesión válida
  - 401 Unauthorized: {:error, message} - Token inválido
  - 404 Not Found: {:error, message} - Admin no existe
  """
  def validate_session(conn, %{"user_id" => user_id, "token" => token}) do
    case UserOps.validate_session(user_id, token) do
      {:ok, admin} ->
        json(conn, %{
          status: "ok",
          message: "Session is valid",
          user: format_admin_response(admin)
        })

      {:error, :invalid_token} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: "Invalid or expired token"
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: "Administrator not found"
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista todos los administradores activos.

  Retorna:
  - 200 OK: Lista de administradores
  - 500 Error: Error al leer datos
  """
  def list_admins(conn, _params) do
    case UserOps.list_admins() do
      {:ok, admins} ->
        json(conn, %{
          status: "ok",
          admins: Enum.map(admins, &format_admin_response/1),
          total: length(admins)
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene un administrador por ID.

  Retorna:
  - 200 OK: {:ok, admin}
  - 404 Not Found: Admin no existe
  """
  def get_admin(conn, %{"user_id" => user_id}) do
    case UserOps.get_admin(user_id) do
      {:ok, admin} ->
        json(conn, %{
          status: "ok",
          user: format_admin_response(admin)
        })

      {:error, :not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: "Administrator not found"
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Actualiza el rol de un administrador (requiere super_admin).

  Parámetros:
  - user_id: ID del admin a actualizar
  - role: nuevo rol
  - updated_by: ID del admin que realiza el cambio

  Retorna:
  - 200 OK: Admin actualizado
  - 400 Bad Request: Validación fallida
  - 403 Forbidden: Sin permisos
  - 404 Not Found: Admin no existe
  """
  def update_role(conn, %{
    "user_id" => user_id,
    "role" => new_role,
    "updated_by" => updated_by
  }) do
    case UserOps.update_admin_role(user_id, new_role, updated_by) do
      {:ok, admin} ->
        json(conn, %{
          status: "ok",
          message: "Administrator role updated",
          user: format_admin_response(admin)
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Suspende la cuenta de un administrador.

  Parámetros:
  - user_id: ID del admin a suspender
  - reason: Razón de la suspensión

  Retorna:
  - 200 OK: Admin suspendido
  - 404 Not Found: Admin no existe
  """
  def suspend(conn, %{"user_id" => user_id, "reason" => reason}) do
    case UserOps.suspend_admin(user_id, reason) do
      {:ok, admin} ->
        json(conn, %{
          status: "ok",
          message: "Administrator suspended",
          user: format_admin_response(admin)
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  # ============================================================================
  # FUNCIONES AUXILIARES
  # ============================================================================

  defp format_admin_response(admin) do
    %{
      id: admin.id,
      name: admin.name,
      email: admin.email,
      role: admin.role,
      status: admin.status,
      permissions: admin.permissions,
      created_at: admin.created_at,
      last_login: admin.last_login
    }
  end
end
