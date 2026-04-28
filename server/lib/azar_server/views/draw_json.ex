defmodule AzarServer.Views.DrawJSON do
  @moduledoc """
  JSON view para respuestas de Sorteos.

  Proporciona funciones para formatear datos de sorteos
  en respuestas JSON consistentes.
  """

  def index(%{draws: draws}) do
    %{
      status: "ok",
      data: Enum.map(draws, &draw_data/1)
    }
  end

  def show(%{draw: draw}) do
    %{
      status: "ok",
      data: draw_data(draw)
    }
  end

  def create(%{draw: draw}) do
    %{
      status: "ok",
      message: "Draw created successfully",
      data: draw_data(draw)
    }
  end

  def update(%{draw: draw}) do
    %{
      status: "ok",
      message: "Draw updated successfully",
      data: draw_data(draw)
    }
  end

  def delete(_) do
    %{
      status: "ok",
      message: "Draw deleted successfully"
    }
  end

  defp draw_data(draw) do
    %{
      id: draw.id,
      name: draw.name,
      description: draw.description,
      status: draw.status,
      draw_date: draw.draw_date,
      created_at: draw.created_at,
      total_tickets: draw.total_tickets,
      available_tickets: draw.available_tickets,
      ticket_price: draw.ticket_price,
      total_investment: draw.total_investment,
      prizes_count: length(draw.prizes || [])
    }
  end
end
