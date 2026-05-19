defmodule AzarSa.Core.Services.ImageService do
  @moduledoc """
  Servicio para procesar y comprimir imágenes subidas.

  Las imágenes se almacenan en priv/static/images/uploads/ como JPEG comprimidos.
  Se usa la herramienta `convert` de ImageMagick si está disponible, de lo contrario
  se almacena el archivo tal cual con un tamaño máximo razonable.
  """

  @upload_dir "priv/static/images/uploads"
  @max_width 800
  @max_height 600
  @jpeg_quality 75

  @doc """
  Procesa una imagen subida: la redimensiona y comprime, luego la guarda
  en el directorio de uploads.

  Retorna la ruta pública accesible (ej: "/images/uploads/draw_abc123.jpg").
  """
  def process_and_save(source_path, draw_id) do
    File.mkdir_p!(@upload_dir)

    dest_filename = "#{draw_id}_#{System.os_time(:millisecond)}.jpg"
    dest_path = Path.join(@upload_dir, dest_filename)

    case compress_image(source_path, dest_path) do
      :ok ->
        public_path = "/images/uploads/#{dest_filename}"
        {:ok, public_path}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Elimina la imagen de un sorteo del sistema de archivos.
  """
  def delete_image(nil), do: :ok
  def delete_image(public_path) do
    file_path = Path.join("priv/static", public_path)
    case File.rm(file_path) do
      :ok -> :ok
      {:error, :enoent} -> :ok
      error -> error
    end
  end

  # Intenta comprimir con ImageMagick, si no está disponible, copia directamente
  defp compress_image(source, dest) do
    case System.find_executable("convert") do
      nil ->
        # Sin ImageMagick: intentar con ffmpeg como fallback
        case System.find_executable("ffmpeg") do
          nil ->
            # Sin herramientas de imagen: copiar directamente (sin comprimir)
            copy_with_size_check(source, dest)

          ffmpeg ->
            compress_with_ffmpeg(ffmpeg, source, dest)
        end

      convert ->
        compress_with_imagemagick(convert, source, dest)
    end
  end

  defp compress_with_imagemagick(convert, source, dest) do
    args = [
      source,
      "-resize", "#{@max_width}x#{@max_height}>",
      "-quality", to_string(@jpeg_quality),
      "-strip",
      dest
    ]

    case System.cmd(convert, args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      {output, _} -> {:error, "ImageMagick error: #{output}"}
    end
  end

  defp compress_with_ffmpeg(ffmpeg, source, dest) do
    args = [
      "-i", source,
      "-vf", "scale='min(#{@max_width},iw)':min'(#{@max_height},ih)':force_original_aspect_ratio=decrease",
      "-q:v", "5",
      "-y",
      dest
    ]

    case System.cmd(ffmpeg, args, stderr_to_stdout: true) do
      {_, 0} -> :ok
      {_output, _} ->
        # ffmpeg failed, just copy the file
        copy_with_size_check(source, dest)
    end
  end

  defp copy_with_size_check(source, dest) do
    case File.stat(source) do
      {:ok, %{size: size}} when size > 5_000_000 ->
        # Si el archivo es mayor a 5MB, rechazar
        {:error, :file_too_large}

      {:ok, _} ->
        File.cp(source, dest)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
