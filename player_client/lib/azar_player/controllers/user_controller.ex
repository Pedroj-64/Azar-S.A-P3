defmodule AzarPlayerClient.Controllers.UserController do
  @moduledoc """
  Controller para gestión de usuarios del cliente jugador.

  Proporciona endpoints para:
  - Registro de nuevos jugadores
  - Autenticación (login)
  - Validación de sesión
  - Obtener perfil del usuario
  - Actualizar perfil
  - Cambiar contraseña
  - Consultar saldo
  - Ver historial de transacciones
  """

  use Phoenix.Controller

  alias AzarPlayerClient.Contexts.Users.Operations, as: UserOps
  alias AzarShared.Errors

  @doc """
  Registra un nuevo jugador en el sistema.

  Parámetros esperados:
  - full_name: String
  - document_number: String (único)
  - email: String (único)
  - phone: String
  - password: String (mínimo 8 caracteres)

  Retorna:
  - 201 Created: {:ok, user} - Usuario creado exitosamente
  - 400 Bad Request: {:error, reasons} - Validación fallida
  - 409 Conflict: {:error, "Email already exists"} - Email ya registrado
  """
  def register(conn, %{"user" => user_params}) do
    case UserOps.register_player(user_params) do
      {:ok, player_user} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "ok",
          message: "Player registered successfully",
          user: format_user_response(player_user)
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
  Autentica un jugador (login).

  Parámetros esperados:
  - email: String
  - password: String

  Retorna:
  - 200 OK: {:ok, {user, token}} - Login exitoso
  - 401 Unauthorized: {:error, "Invalid credentials"} - Credenciales incorrectas
  - 404 Not Found: {:error, "User not found"} - Usuario no existe
  """
  def authenticate(conn, %{"email" => email, "password" => password}) do
    case UserOps.authenticate(email, password) do
      {:ok, {player_user, session_token}} ->
        conn
        |> put_resp_cookie("auth_token", session_token, http_only: true)
        |> json(%{
          status: "ok",
          message: "Authentication successful",
          user: format_user_response(player_user),
          token: session_token
        })

      {:error, :invalid_credentials} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: "Invalid email or password"
        })

      {:error, :user_not_found} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: "User not found"
        })

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Valida la sesión actual del usuario.

  Parámetros:
  - token: String (en header Authorization o cookie)

  Retorna:
  - 200 OK: {:ok, user} - Sesión válida
  - 401 Unauthorized: {:error, "Invalid session"} - Sesión inválida
  """
  def validate_session(conn, %{"token" => token}) do
    case UserOps.validate_session(token, DateTime.utc_now()) do
      {:ok, player_user} ->
        json(conn, %{
          status: "ok",
          message: "Session is valid",
          user: format_user_response(player_user)
        })

      {:error, reason} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene el perfil del usuario actual.

  Retorna:
  - 200 OK: Perfil completo del usuario
  - 401 Unauthorized: Usuario no autenticado
  """
  def get_profile(conn, _params) do
    user_id = conn.assigns[:current_user_id]

    case UserOps.get_profile(user_id) do
      {:ok, profile} ->
        json(conn, %{
          status: "ok",
          profile: profile
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Actualiza el perfil del usuario.

  Parámetros opcionales:
  - full_name: String
  - phone: String
  - preferences: Map

  Retorna:
  - 200 OK: Perfil actualizado
  - 400 Bad Request: Validación fallida
  """
  def update_profile(conn, %{"profile" => profile_params}) do
    user_id = conn.assigns[:current_user_id]

    case UserOps.update_profile(user_id, profile_params) do
      {:ok, profile} ->
        json(conn, %{
          status: "ok",
          message: "Profile updated successfully",
          profile: profile
        })

      {:error, reasons} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: "Update failed",
          errors: reasons
        })
    end
  end

  @doc """
  Cambia la contraseña del usuario.

  Parámetros:
  - old_password: String
  - new_password: String
  - confirm_password: String

  Retorna:
  - 200 OK: Contraseña cambiada exitosamente
  - 401 Unauthorized: Contraseña actual incorrecta
  - 400 Bad Request: Validación fallida
  """
  def change_password(conn, %{"old_password" => old_pwd, "new_password" => new_pwd}) do
    user_id = conn.assigns[:current_user_id]

    case UserOps.change_password(user_id, old_pwd, new_pwd) do
      {:ok, _user} ->
        json(conn, %{
          status: "ok",
          message: "Password changed successfully"
        })

      {:error, :invalid_password} ->
        conn
        |> put_status(:unauthorized)
        |> json(%{
          status: "error",
          message: "Current password is incorrect"
        })

      {:error, reasons} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: "Password change failed",
          errors: reasons
        })
    end
  end

  @doc """
  Obtiene el saldo disponible del usuario.

  Retorna:
  - 200 OK: Saldo en formato {:ok, decimal}
  - 404 Not Found: Usuario no existe
  """
  def get_balance(conn, _params) do
    user_id = conn.assigns[:current_user_id]

    case UserOps.get_balance(user_id) do
      {:ok, balance} ->
        json(conn, %{
          status: "ok",
          balance: balance |> Decimal.to_string()
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene el historial de transacciones del usuario.

  Parámetros:
  - page: Integer (default: 1)
  - limit: Integer (default: 20, máximo 100)

  Retorna:
  - 200 OK: Lista de transacciones paginadas
  """
  def list_balance_history(conn, params) do
    user_id = conn.assigns[:current_user_id]
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "20") |> min(100)

    case UserOps.list_balance_history(user_id, page, limit) do
      {:ok, transactions} ->
        json(conn, %{
          status: "ok",
          transactions: transactions,
          page: page,
          limit: limit
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
  Obtiene estadísticas de la cuenta del usuario.

  Retorna:
  - 200 OK: Estadísticas (total gasto, total ganado, número de compras, etc.)
  """
  def get_statistics(conn, _params) do
    user_id = conn.assigns[:current_user_id]

    case UserOps.get_statistics(user_id) do
      {:ok, stats} ->
        json(conn, %{
          status: "ok",
          statistics: stats
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  # Helpers

  @doc """
  Formatea la respuesta del usuario para JSON (sin datos sensibles).
  """
  defp format_user_response(player_user) do
    %{
      id: player_user.id,
      full_name: player_user.full_name,
      email: player_user.email,
      phone: player_user.phone,
      account_balance: player_user.account_balance |> Decimal.to_string(),
      status: player_user.status,
      created_at: player_user.created_at
    }
  end
end
