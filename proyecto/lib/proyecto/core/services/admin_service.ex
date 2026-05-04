defmodule AzarSa.Core.Services.AdminService do
  @moduledoc """
  Servicio para la gestión y autenticación de Administradores.
  
  Los administradores están separados de los clientes (jugadores) y se guardan
  en priv/data/admins.json.
  """

  alias AzarSa.Core.Data.Store

  @admins_file "admins.json"

  @doc """
  Autentica a un administrador dado su username y password.
  """
  def authenticate(username, password) do
    admins = Store.read(@admins_file)

    case Enum.find(admins, fn a -> a["username"] == username end) do
      nil ->
        {:error, :admin_not_found}

      admin ->
        if admin["password_hash"] == hash(password) do
          # No devolvemos el hash a la vista
          clean_admin = Map.delete(admin, "password_hash")
          {:ok, clean_admin}
        else
          {:error, :invalid_password}
        end
    end
  end

  @doc """
  Crea un administrador (usualmente solo por consola o seeds).
  """
  def create_admin(username, password) do
    admins = Store.read(@admins_file)

    if Enum.any?(admins, fn a -> a["username"] == username end) do
      {:error, :admin_exists}
    else
      admin = %{
        "id" => :crypto.strong_rand_bytes(4) |> Base.encode16(),
        "username" => username,
        "password_hash" => hash(password),
        "created_at" => DateTime.utc_now() |> DateTime.to_string()
      }

      Store.write(@admins_file, [admin | admins])
      {:ok, Map.delete(admin, "password_hash")}
    end
  end

  defp hash(password) do
    :crypto.hash(:sha256, password)
    |> Base.encode16(case: :lower)
  end
end
