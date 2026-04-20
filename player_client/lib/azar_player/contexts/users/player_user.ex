defmodule AzarPlayer.Contexts.Users.PlayerUser do
  @moduledoc """
  Struct que representa un Usuario Jugador en el sistema.

  Los jugadores pueden:
  - Registrarse en el sistema
  - Comprar billetes completos o fracciones
  - Ver historial de compras
  - Consultar premios obtenidos
  - Devolver billetes no jugados
  """

  @enforce_keys [:id, :full_name, :document_number, :password_hash]
  defstruct [
    :id,                          # UUID único del jugador
    :full_name,                   # Nombre completo
    :document_number,             # Cédula/Documento de identidad (único)
    :password_hash,               # Contraseña hasheada con bcrypt
    :email,                       # Email (opcional)
    :phone,                       # Teléfono (opcional)
    :account_balance,             # Saldo disponible en la cuenta
    :credit_card_last_digits,     # Últimos 4 dígitos de tarjeta (simulada)
    :status,                      # Estado: "active", "inactive", "suspended"
    :created_at,                  # Fecha de registro
    :last_login,                  # Fecha del último login
    :total_spent,                 # Total gastado en el sistema
    :total_won,                   # Total ganado en premios
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          full_name: String.t(),
          document_number: String.t(),
          password_hash: String.t(),
          email: String.t() | nil,
          phone: String.t() | nil,
          account_balance: number(),
          credit_card_last_digits: String.t() | nil,
          status: String.t(),
          created_at: DateTime.t(),
          last_login: DateTime.t() | nil,
          total_spent: number(),
          total_won: number(),
          remarks: String.t() | nil
        }

  @doc """
  Crea un nuevo usuario jugador.

  Parámetros:
  - full_name: nombre completo del jugador
  - document_number: número de documento único
  - password_hash: contraseña ya hasheada
  """
  @spec new(map()) :: t()
  def new(attrs) do
    %__MODULE__{
      id: attrs[:id] || generate_id(),
      full_name: attrs[:full_name],
      document_number: attrs[:document_number],
      password_hash: attrs[:password_hash],
      email: attrs[:email],
      phone: attrs[:phone],
      account_balance: attrs[:account_balance] || 0.0,
      credit_card_last_digits: attrs[:credit_card_last_digits],
      status: "active",
      created_at: DateTime.utc_now(),
      last_login: nil,
      total_spent: 0.0,
      total_won: 0.0,
      remarks: attrs[:remarks]
    }
  end

  defp generate_id do
    UUID.uuid4()
  end
end
