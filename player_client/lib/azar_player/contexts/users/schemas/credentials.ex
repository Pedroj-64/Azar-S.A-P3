defmodule AzarPlayerClient.Contexts.Users.Schemas.Credentials do
  @moduledoc """
  Struct que representa las Credenciales de un Jugador.

  Contiene información de autenticación (hash de contraseña, tokens, etc).
  Este schema es SENSIBLE y nunca debe ser expuesto en respuestas HTTP.
  """

  defstruct [
    :user_id,                     # ID del jugador
    :password_hash,               # Hash bcrypt de contraseña
    :session_tokens,              # Lista de tokens activos
    :last_password_change,        # Fecha del último cambio de contraseña
    :password_change_required,    # ¿Requiere cambio de contraseña?
    :failed_login_attempts,       # Contador de intentos fallidos
    :last_failed_attempt,         # Timestamp del último intento fallido
    :account_locked_until         # Timestamp hasta que la cuenta está bloqueada
  ]

  @type t :: %__MODULE__{
          user_id: String.t(),
          password_hash: String.t(),
          session_tokens: [String.t()],
          last_password_change: DateTime.t(),
          password_change_required: boolean(),
          failed_login_attempts: integer(),
          last_failed_attempt: DateTime.t() | nil,
          account_locked_until: DateTime.t() | nil
        }

  @doc """
  Crea nuevas credenciales.
  """
  def new(attrs) do
    %__MODULE__{
      user_id: attrs[:user_id],
      password_hash: attrs[:password_hash],
      session_tokens: [],
      last_password_change: DateTime.utc_now(),
      password_change_required: false,
      failed_login_attempts: 0,
      last_failed_attempt: nil,
      account_locked_until: nil
    }
  end

  @doc """
  Verifica si la cuenta está bloqueada.
  """
  def is_locked?(%__MODULE__{} = credentials) do
    case credentials.account_locked_until do
      nil -> false
      locked_until -> DateTime.compare(DateTime.utc_now(), locked_until) == :lt
    end
  end
end
