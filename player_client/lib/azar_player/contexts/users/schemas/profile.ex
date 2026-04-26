defmodule AzarPlayer.Contexts.Users.Schemas.Profile do
  @moduledoc """
  Struct que representa el Perfil público de un Jugador.

  Contiene información de contacto y preferencias del jugador
  que puede ser vista/actualizada por el jugador mismo.

  Nota: No incluye información sensible como contraseña o saldo.
  """

  defstruct [
    :user_id,                     # ID del jugador
    :full_name,                   # Nombre completo
    :email,                       # Email
    :phone,                       # Teléfono
    :document_number,             # Número de documento
    :created_at,                  # Fecha de creación de cuenta
    :last_updated,                # Última actualización del perfil
    :verified_email,              # ¿Email verificado?
    :verified_phone,              # ¿Teléfono verificado?
    :preferences                   # Map de preferencias del jugador
  ]

  @type t :: %__MODULE__{
          user_id: String.t(),
          full_name: String.t(),
          email: String.t() | nil,
          phone: String.t() | nil,
          document_number: String.t(),
          created_at: DateTime.t(),
          last_updated: DateTime.t(),
          verified_email: boolean(),
          verified_phone: boolean(),
          preferences: map()
        }

  @doc """
  Crea un nuevo perfil desde los datos del jugador.
  """
  def new(user) do
    %__MODULE__{
      user_id: user.id,
      full_name: user.full_name,
      email: user.email,
      phone: user.phone,
      document_number: user.document_number,
      created_at: user.created_at,
      last_updated: DateTime.utc_now(),
      verified_email: user.email != nil,
      verified_phone: user.phone != nil,
      preferences: %{}
    }
  end
end
