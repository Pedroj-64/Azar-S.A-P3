defmodule ProyectoWeb.FormatHelpers do
  @moduledoc """
  Helpers de formato compartidos entre todas las vistas.
  Evita duplicación de `fmt/1`, `format_number/1` y `draw_img/1`.
  """

  @doc "Formatea un entero con separador de miles (punto)."
  def fmt(n) when is_integer(n) do
    n
    |> Integer.to_string()
    |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1.")
    |> String.reverse()
  end

  def fmt(_), do: "0"

  @doc "Alias de `fmt/1` para compatibilidad."
  def format_number(n), do: fmt(n)

  @doc "Retorna la imagen del sorteo: imagen personalizada si existe, o SVG por tier."
  def draw_img(draw) when is_map(draw) do
    custom = draw["image"] || draw[:image]

    if custom && custom != "" do
      custom
    else
      price = draw["ticket_price"] || draw[:ticket_price] || 0

      cond do
        price >= 50_000 -> "/images/sorteo_oro.svg"
        price >= 20_000 -> "/images/sorteo_plata.svg"
        true -> "/images/sorteo_bronce.svg"
      end
    end
  end
end
