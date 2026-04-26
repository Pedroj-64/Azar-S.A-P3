defmodule AzarServer.ErrorJSON do
  @moduledoc """
  Formatea errores HTTP como JSON.

  Transforma errores internos en respuestas JSON consistentes.
  """

  @doc """
  Renderiza error de recurso no encontrado.
  """
  def render("404.json", _assigns) do
    %{
      error: "not_found",
      message: "Recurso no encontrado",
      status: 404
    }
  end

  @doc """
  Renderiza error de validación.
  """
  def render("422.json", assigns) do
    %{
      error: "unprocessable_entity",
      message: Map.get(assigns, :message, "Error en la validación"),
      status: 422,
      details: Map.get(assigns, :details, %{})
    }
  end

  @doc """
  Renderiza error interno del servidor.
  """
  def render("500.json", _assigns) do
    %{
      error: "internal_server_error",
      message: "Error interno del servidor",
      status: 500
    }
  end

  @doc """
  Renderiza error genérico.
  """
  def render("error.json", assigns) do
    %{
      error: Map.get(assigns, :code, "error"),
      message: Map.get(assigns, :message, "Ha ocurrido un error"),
      status: Map.get(assigns, :status, 400),
      details: Map.get(assigns, :details, %{})
    }
  end
end
