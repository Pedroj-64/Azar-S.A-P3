defmodule AzarShared.Utils.CryptoHelper do
  @moduledoc """
  Funciones auxiliares para criptografía y seguridad.

  Contiene utilidades para:
  - Hash de contraseñas (bcrypt)
  - Generación de tokens
  - Validación de contraseñas
  - Cifrado básico
  """

  @doc """
  Genera el hash de una contraseña usando bcrypt.

  Retorna: {:ok, hashed_password} o {:error, String.t()}

  Ejemplo:
    CryptoHelper.hash_password("micontraseña123")
  """
  @spec hash_password(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def hash_password(password) when is_binary(password) do
    try do
      hashed = Bcrypt.hash_pwd_salt(password)
      {:ok, hashed}
    rescue
      error ->
        {:error, "Error al hashear contraseña: #{inspect(error)}"}
    end
  end

  def hash_password(_), do: {:error, "La contraseña debe ser un texto"}

  @doc """
  Valida si una contraseña coincide con su hash.

  Retorna: true si coincide, false en caso contrario

  Ejemplo:
    CryptoHelper.verify_password("micontraseña123", hashed)
  """
  @spec verify_password(String.t(), String.t()) :: boolean()
  def verify_password(password, hash) when is_binary(password) and is_binary(hash) do
    try do
      Bcrypt.verify_pass(password, hash)
    rescue
      _ -> false
    end
  end

  def verify_password(_, _), do: false

  @doc """
  Valida si una contraseña cumple con requisitos de seguridad.

  Requisitos:
  - Mínimo 8 caracteres
  - Al menos una mayúscula
  - Al menos una minúscula
  - Al menos un número

  Retorna: {:ok, password} o {:error, String.t()}
  """
  @spec validate_password_strength(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_password_strength(password) when is_binary(password) do
    cond do
      String.length(password) < 8 ->
        {:error, "La contraseña debe tener mínimo 8 caracteres"}

      not String.match?(password, ~r/[A-Z]/) ->
        {:error, "La contraseña debe contener al menos una mayúscula"}

      not String.match?(password, ~r/[a-z]/) ->
        {:error, "La contraseña debe contener al menos una minúscula"}

      not String.match?(password, ~r/[0-9]/) ->
        {:error, "La contraseña debe contener al menos un número"}

      true ->
        {:ok, password}
    end
  end

  def validate_password_strength(_), do: {:error, "La contraseña debe ser un texto"}

  @doc """
  Genera un token aleatorio para sesiones.

  Retorna: string de 32 caracteres hexadecimales

  Ejemplo:
    CryptoHelper.generate_token()
    # "a3f8c2e9d1b4f7a6c8e2b5d9f1a3c5e7"
  """
  @spec generate_token() :: String.t()
  def generate_token do
    16
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end

  @doc """
  Genera un UUID v4 único.

  Retorna: string UUID válido

  Ejemplo:
    CryptoHelper.generate_uuid()
    # "f47ac10b-58cc-4372-a567-0e02b2c3d479"
  """
  @spec generate_uuid() :: String.t()
  def generate_uuid do
    UUID.uuid4()
  end

  @doc """
  Genera un token de confirmación de email.

  Retorna: {token, expires_at}
  """
  @spec generate_confirmation_token() :: {String.t(), DateTime.t()}
  def generate_confirmation_token do
    token = generate_token()
    expires_at = DateTime.add(DateTime.utc_now(), 24 * 60 * 60, :second)  # 24 horas
    {token, expires_at}
  end

  @doc """
  Verifica si un token de confirmación ha expirado.

  Retorna: true si expiró, false si aún es válido
  """
  @spec token_expired?(DateTime.t()) :: boolean()
  def token_expired?(expires_at) when is_struct(expires_at, DateTime) do
    DateTime.compare(expires_at, DateTime.utc_now()) == :lt
  end

  def token_expired?(_), do: true

  @doc """
  Codifica un valor en base64.

  Ejemplo:
    CryptoHelper.encode_base64("test")
    # "dGVzdA=="
  """
  @spec encode_base64(String.t()) :: String.t()
  def encode_base64(text) when is_binary(text) do
    Base.encode64(text)
  end

  def encode_base64(_), do: ""

  @doc """
  Decodifica un valor de base64.

  Retorna: {:ok, decoded} o {:error, String.t()}
  """
  @spec decode_base64(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def decode_base64(encoded) when is_binary(encoded) do
    try do
      {:ok, Base.decode64!(encoded)}
    rescue
      error ->
        {:error, "Error al decodificar base64: #{inspect(error)}"}
    end
  end

  def decode_base64(_), do: {:error, "El texto debe ser base64 válido"}

  @doc """
  Genera un hash SHA256 de un string.

  Útil para generar checksums o identificadores.
  """
  @spec sha256(String.t()) :: String.t()
  def sha256(text) when is_binary(text) do
    :crypto.hash(:sha256, text)
    |> Base.encode16(case: :lower)
  end

  def sha256(_), do: ""
end
