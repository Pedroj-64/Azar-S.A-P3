defmodule AzarAdmin.Contexts.Users.Schemas.Credentials do
  @moduledoc """
  Schema que contiene información de credenciales de un administrador.

  Usado internamente para operaciones de autenticación y validación.
  """

  @enforce_keys [:email, :password_hash]
  defstruct [
    :email,
    :password_hash,
    :last_changed_at
  ]

  @type t :: %__MODULE__{
          email: String.t(),
          password_hash: String.t(),
          last_changed_at: DateTime.t() | nil
        }
end
