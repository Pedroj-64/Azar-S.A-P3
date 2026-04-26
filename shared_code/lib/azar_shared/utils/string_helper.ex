defmodule AzarShared.Utils.StringHelper do
  @moduledoc """
  Funciones auxiliares para manipulación de strings.

  Contiene utilidades para:
  - Formateo de strings
  - Padding y truncado
  - Conversiones
  - Limpieza de datos
  """

  @doc """
  Formatea un nombre capitalizando la primera letra de cada palabra.

  Ejemplo:
    StringHelper.titleize("juan perez lopez")
    # "Juan Perez Lopez"
  """
  @spec titleize(String.t()) :: String.t()
  def titleize(text) when is_binary(text) do
    text
    |> String.split(" ")
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end

  def titleize(_), do: ""

  @doc """
  Trunca un string a una longitud máxima y agrega puntos suspensivos.

  Ejemplo:
    StringHelper.truncate("Este es un texto muy largo", 10)
    # "Este es un..."
  """
  @spec truncate(String.t(), integer()) :: String.t()
  def truncate(text, max_length) when is_binary(text) and is_integer(max_length) do
    if String.length(text) > max_length do
      String.slice(text, 0, max_length) <> "..."
    else
      text
    end
  end

  def truncate(text, _), do: text

  @doc """
  Rellena un string a la izquierda con un carácter.

  Ejemplo:
    StringHelper.pad_left("123", 5, "0")
    # "00123"
  """
  @spec pad_left(String.t(), integer(), String.t()) :: String.t()
  def pad_left(text, length, padding) when is_binary(text) and is_integer(length) and is_binary(padding) do
    String.pad_leading(text, length, padding)
  end

  def pad_left(text, _, _), do: text

  @doc """
  Rellena un string a la derecha con un carácter.

  Ejemplo:
    StringHelper.pad_right("123", 5, "0")
    # "12300"
  """
  @spec pad_right(String.t(), integer(), String.t()) :: String.t()
  def pad_right(text, length, padding) when is_binary(text) and is_integer(length) and is_binary(padding) do
    String.pad_trailing(text, length, padding)
  end

  def pad_right(text, _, _), do: text

  @doc """
  Limpia espacios en blanco al inicio y final, y normaliza espacios internos.

  Ejemplo:
    StringHelper.normalize("  Juan    Perez  ")
    # "Juan Perez"
  """
  @spec normalize(String.t()) :: String.t()
  def normalize(text) when is_binary(text) do
    text
    |> String.trim()
    |> String.replace(~r/\s+/, " ")
  end

  def normalize(_), do: ""

  @doc """
  Verifica si un string contiene solo letras y espacios.

  Retorna: true si es válido, false en caso contrario
  """
  @spec is_text_only?(String.t()) :: boolean()
  def is_text_only?(text) when is_binary(text) do
    String.match?(text, ~r/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/)
  end

  def is_text_only?(_), do: false

  @doc """
  Verifica si un string contiene solo números.
  """
  @spec is_numeric?(String.t()) :: boolean()
  def is_numeric?(text) when is_binary(text) do
    String.match?(text, ~r/^\d+$/)
  end

  def is_numeric?(_), do: false

  @doc """
  Verifica si un string contiene solo caracteres alfanuméricos.
  """
  @spec is_alphanumeric?(String.t()) :: boolean()
  def is_alphanumeric?(text) when is_binary(text) do
    String.match?(text, ~r/^[a-zA-Z0-9]+$/)
  end

  def is_alphanumeric?(_), do: false

  @doc """
  Convierte un string a slug (minúsculas, sin espacios, con guiones).

  Ejemplo:
    StringHelper.to_slug("Juan Perez García")
    # "juan-perez-garcia"
  """
  @spec to_slug(String.t()) :: String.t()
  def to_slug(text) when is_binary(text) do
    text
    |> String.downcase()
    |> String.replace(~r/[^\w\s-]/, "")
    |> String.replace(~r/[\s_-]+/, "-")
    |> String.trim("-")
  end

  def to_slug(_), do: ""

  @doc """
  Enmascaraba un string mostrando solo los últimos N caracteres.

  Ejemplo:
    StringHelper.mask_sensitive("1234567890", 4)
    # "****567890"
  """
  @spec mask_sensitive(String.t(), integer()) :: String.t()
  def mask_sensitive(text, show_last) when is_binary(text) and is_integer(show_last) and show_last >= 0 do
    length = String.length(text)

    if show_last >= length do
      text
    else
      mask_length = length - show_last
      masked = String.duplicate("*", mask_length)
      visible = String.slice(text, mask_length..-1)
      masked <> visible
    end
  end

  def mask_sensitive(text, _), do: text

  @doc """
  Divide un string en chunks de tamaño específico.

  Ejemplo:
    StringHelper.chunk_string("12345678", 3)
    # ["123", "456", "78"]
  """
  @spec chunk_string(String.t(), integer()) :: list(String.t())
  def chunk_string(text, chunk_size) when is_binary(text) and is_integer(chunk_size) and chunk_size > 0 do
    text
    |> String.codepoints()
    |> Enum.chunk_every(chunk_size)
    |> Enum.map(&Enum.join/1)
  end

  def chunk_string(_, _), do: []

  @doc """
  Compara dos strings ignorando mayúsculas/minúsculas.

  Retorna: true si son iguales (case-insensitive)
  """
  @spec case_insensitive_equal?(String.t(), String.t()) :: boolean()
  def case_insensitive_equal?(text1, text2) when is_binary(text1) and is_binary(text2) do
    String.downcase(text1) == String.downcase(text2)
  end

  def case_insensitive_equal?(_, _), do: false

  @doc """
  Formatea un número de documento (CDI) con guiones.

  Ejemplo:
    StringHelper.format_document("123456789")
    # "12-345-678-9"
  """
  @spec format_document(String.t()) :: String.t()
  def format_document(doc) when is_binary(doc) do
    doc = String.replace(doc, ~r/\D/, "")

    case String.length(doc) do
      8 -> String.slice(doc, 0..1) <> "-" <> String.slice(doc, 2..4) <> "-" <> String.slice(doc, 5..6) <> "-" <> String.slice(doc, 7..7)
      9 -> String.slice(doc, 0..1) <> "-" <> String.slice(doc, 2..4) <> "-" <> String.slice(doc, 5..7) <> "-" <> String.slice(doc, 8..8)
      _ -> doc
    end
  end

  def format_document(_), do: ""

  @doc """
  Genera un string random alfanumérico.

  Ejemplo:
    StringHelper.random_string(10)
    # "aBcDeF1234"
  """
  @spec random_string(integer()) :: String.t()
  def random_string(length) when is_integer(length) and length > 0 do
    chars = String.codepoints("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

    1..length
    |> Enum.map(fn _ -> Enum.random(chars) end)
    |> Enum.join()
  end

  def random_string(_), do: ""

  @doc """
  Verifica si un string es un palíndromo.

  Ejemplo:
    StringHelper.is_palindrome?("radar")
    # true
  """
  @spec is_palindrome?(String.t()) :: boolean()
  def is_palindrome?(text) when is_binary(text) do
    cleaned = text |> String.downcase() |> String.replace(~r/[^a-z0-9]/, "")
    cleaned == String.reverse(cleaned)
  end

  def is_palindrome?(_), do: false
end
