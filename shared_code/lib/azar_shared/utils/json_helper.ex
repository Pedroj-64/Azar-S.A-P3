defmodule AzarShared.Utils.JsonHelper do
  @moduledoc """
  Funciones auxiliares para manejo de archivos JSON.

  Contiene utilidades para:
  - Leer archivos JSON
  - Escribir archivos JSON
  - Validar JSON
  """

  @doc """
  Lee un archivo JSON y retorna el contenido decodificado.

  Retorna: {:ok, map()} o {:error, String.t()}

  Ejemplo:
    JsonHelper.read_file("priv/data/draws.json")
  """
  @spec read_file(String.t()) :: {:ok, any()} | {:error, String.t()}
  def read_file(file_path) when is_binary(file_path) do
    case File.read(file_path) do
      {:ok, content} ->
        try do
          decoded = Jason.decode!(content)
          {:ok, decoded}
        rescue
          error ->
            {:error, "Error al decodificar JSON: #{inspect(error)}"}
        end

      {:error, reason} ->
        {:error, "No se puede leer el archivo: #{inspect(reason)}"}
    end
  end

  def read_file(_), do: {:error, "La ruta debe ser un texto"}

  @doc """
  Escribe contenido en un archivo JSON.

  Retorna: :ok o {:error, String.t()}

  Ejemplo:
    JsonHelper.write_file("priv/data/draws.json", %{data: [1, 2, 3]})
  """
  @spec write_file(String.t(), any()) :: :ok | {:error, String.t()}
  def write_file(file_path, data) when is_binary(file_path) do
    try do
      encoded = Jason.encode!(data, pretty: true)

      case File.write(file_path, encoded) do
        :ok -> :ok
        {:error, reason} -> {:error, "Error al escribir archivo: #{inspect(reason)}"}
      end
    rescue
      error ->
        {:error, "Error al codificar JSON: #{inspect(error)}"}
    end
  end

  def write_file(_, _), do: {:error, "Parámetros inválidos"}

  @doc """
  Valida si una cadena es JSON válido.

  Retorna: true si es válido, false en caso contrario
  """
  @spec is_valid_json?(String.t()) :: boolean()
  def is_valid_json?(json_string) when is_binary(json_string) do
    try do
      Jason.decode!(json_string)
      true
    rescue
      _ -> false
    end
  end

  def is_valid_json?(_), do: false

  @doc """
  Decodifica una cadena JSON.

  Retorna: {:ok, decoded} o {:error, String.t()}
  """
  @spec decode(String.t()) :: {:ok, any()} | {:error, String.t()}
  def decode(json_string) when is_binary(json_string) do
    try do
      {:ok, Jason.decode!(json_string)}
    rescue
      error ->
        {:error, "Error al decodificar: #{inspect(error)}"}
    end
  end

  def decode(_), do: {:error, "Debe ser una cadena de texto"}

  @doc """
  Codifica un valor a JSON.

  Retorna: {:ok, json_string} o {:error, String.t()}
  """
  @spec encode(any()) :: {:ok, String.t()} | {:error, String.t()}
  def encode(data) do
    try do
      {:ok, Jason.encode!(data)}
    rescue
      error ->
        {:error, "Error al codificar: #{inspect(error)}"}
    end
  end

  @doc """
  Lee un archivo JSON y obtiene un valor por llave.

  Retorna: {:ok, value} o {:error, String.t()}

  Ejemplo:
    JsonHelper.read_key_from_file("priv/data/draws.json", ["data", "items"])
  """
  @spec read_key_from_file(String.t(), list(any())) :: {:ok, any()} | {:error, String.t()}
  def read_key_from_file(file_path, keys) when is_binary(file_path) and is_list(keys) do
    case read_file(file_path) do
      {:ok, data} ->
        case get_in(data, keys) do
          nil -> {:error, "Llave no encontrada"}
          value -> {:ok, value}
        end

      error -> error
    end
  end

  def read_key_from_file(_, _), do: {:error, "Parámetros inválidos"}

  @doc """
  Escribe un valor en un archivo JSON bajo una llave específica.

  Retorna: :ok o {:error, String.t()}

  Ejemplo:
    JsonHelper.write_key_to_file("priv/data/draws.json", ["data"], new_value)
  """
  @spec write_key_to_file(String.t(), list(any()), any()) :: :ok | {:error, String.t()}
  def write_key_to_file(file_path, keys, value) when is_binary(file_path) and is_list(keys) do
    case read_file(file_path) do
      {:ok, data} ->
        new_data = put_in(data, keys, value)
        write_file(file_path, new_data)

      error -> error
    end
  end

  def write_key_to_file(_, _, _), do: {:error, "Parámetros inválidos"}

  @doc """
  Agrega un elemento a una lista dentro de un archivo JSON.

  Retorna: :ok o {:error, String.t()}
  """
  @spec append_to_array(String.t(), list(any()), any()) :: :ok | {:error, String.t()}
  def append_to_array(file_path, keys, element) when is_binary(file_path) and is_list(keys) do
    case read_file(file_path) do
      {:ok, data} ->
        current_array = get_in(data, keys) || []
        new_array = current_array ++ [element]
        new_data = put_in(data, keys, new_array)
        write_file(file_path, new_data)

      error -> error
    end
  end

  def append_to_array(_, _, _), do: {:error, "Parámetros inválidos"}
end
