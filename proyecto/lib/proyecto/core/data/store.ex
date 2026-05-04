defmodule AzarSa.Core.Data.Store do
  @base_path "priv/data"

  # 🔹 Asegura que el directorio base y subdirectorios existan
  def ensure_dir(path \\ "") do
    full_dir = Path.join(@base_path, path) |> Path.dirname()
    File.mkdir_p!(full_dir)
  end

  # 🔹 Leer JSON (Devuelve [] si no existe para evitar que el programa truene)
  def read(file) do
    path = full_path(file)

    case File.read(path) do
      {:ok, content} ->
        Jason.decode!(content)

      {:error, _} ->
        # devolver lista vacía que nil para poder usar Enum después
        []
    end
  end

  # 🔹 Escribir JSON (Asegura la carpeta justo antes de escribir)
  def write(file, data) do
    path = full_path(file)
    # Crea la carpeta si no existe
    File.mkdir_p!(Path.dirname(path))

    json = Jason.encode!(data, pretty: true)
    File.write!(path, json)
  end

  # 🔹 Genera la ruta completa dentro de priv/data
  defp full_path(file) do
    Path.join(@base_path, file)
  end

  # 🔹 Listar sorteos disponibles
  def list_draws do
    path = Path.join("priv/data/draws", "*.json")

    Path.wildcard(path)
    |> Enum.map(fn file ->
      {:ok, content} = File.read(file)
      Jason.decode!(content)
    end)
  end

  # 🔹 Eliminar un archivo JSON (usado para borrar sorteos)
  def delete(file) do
    path = full_path(file)

    case File.rm(path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end
end
