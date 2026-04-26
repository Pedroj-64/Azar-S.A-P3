defmodule AzarShared.Utils.Validations do
  @moduledoc """
  Validadores reutilizables en todo el sistema.

  Contiene funciones para validar:
  - Emails
  - Documentos de identidad
  - Montos monetarios
  - Fechas
  """

  @doc """
  Valida si un email tiene formato correcto.

  Retorna: {:ok, email} o {:error, "Email inválido"}
  """
  @spec validate_email(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_email(email) when is_binary(email) do
    email = String.trim(email)

    if String.match?(email, ~r/^[^\s@]+@[^\s@]+\.[^\s@]+$/) do
      {:ok, email}
    else
      {:error, "Email inválido"}
    end
  end

  def validate_email(_), do: {:error, "Email debe ser un texto"}

  @doc """
  Valida si un documento de identidad es válido.

  Solo verifica formato básico (números y guiones).

  Retorna: {:ok, document} o {:error, "Documento inválido"}
  """
  @spec validate_document(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_document(document) when is_binary(document) do
    document = String.trim(document)

    if String.match?(document, ~r/^[\d\-]{5,}$/) do
      {:ok, document}
    else
      {:error, "Documento inválido"}
    end
  end

  def validate_document(_), do: {:error, "Documento debe ser un texto"}

  @doc """
  Valida si un monto es válido (número positivo).

  Retorna: {:ok, amount} o {:error, "Monto inválido"}
  """
  @spec validate_amount(number()) :: {:ok, number()} | {:error, String.t()}
  def validate_amount(amount) when is_number(amount) and amount > 0 do
    {:ok, amount}
  end

  def validate_amount(_), do: {:error, "El monto debe ser un número positivo"}

  @doc """
  Valida si una fecha es posterior a la actual.

  Retorna: {:ok, date} o {:error, "Fecha inválida"}
  """
  @spec validate_future_date(DateTime.t()) :: {:ok, DateTime.t()} | {:error, String.t()}
  def validate_future_date(date) when is_struct(date, DateTime) do
    now = DateTime.utc_now()

    if DateTime.compare(date, now) == :gt do
      {:ok, date}
    else
      {:error, "La fecha debe ser futura"}
    end
  end

  def validate_future_date(_), do: {:error, "La fecha debe ser un DateTime"}

  @doc """
  Valida si un string no está vacío.

  Retorna: {:ok, string} o {:error, "Campo vacío"}
  """
  @spec validate_non_empty(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_non_empty(text) when is_binary(text) do
    trimmed = String.trim(text)

    if byte_size(trimmed) > 0 do
      {:ok, trimmed}
    else
      {:error, "El campo no puede estar vacío"}
    end
  end

  def validate_non_empty(_), do: {:error, "Debe ser un texto"}

  @doc """
  Valida si un número de billete es válido (001-999).

  Retorna: {:ok, number} o {:error, "Número inválido"}
  """
  @spec validate_ticket_number(String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def validate_ticket_number(number) when is_binary(number) do
    number = String.trim(number)

    case Integer.parse(number) do
      {num, ""} when num >= 1 and num <= 999 ->
        {:ok, String.pad_leading(number, 3, "0")}

      _ ->
        {:error, "El número de billete debe estar entre 001 y 999"}
    end
  end

  def validate_ticket_number(_), do: {:error, "El número debe ser un texto"}

  @doc """
  Valida si un monto no excede un límite máximo.

  Retorna: {:ok, amount} o {:error, "Monto excede límite"}
  """
  @spec validate_amount_limit(number(), number()) :: {:ok, number()} | {:error, String.t()}
  def validate_amount_limit(amount, max_limit) when is_number(amount) and is_number(max_limit) do
    if amount <= max_limit do
      {:ok, amount}
    else
      {:error, "El monto excede el límite de #{max_limit}"}
    end
  end

  def validate_amount_limit(_, _), do: {:error, "Los montos deben ser números"}
end
