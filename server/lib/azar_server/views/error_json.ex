defmodule AzarServer.Views.ErrorJSON do
  @moduledoc """
  JSON view para respuestas de error.

  Proporciona funciones para formatear errores
  en respuestas JSON consistentes.
  """

  def render(template, assigns) do
    render_status(assigns.status, template, assigns)
  end

  defp render_status(404, _template, _assigns) do
    %{
      status: "error",
      code: 404,
      message: "Resource not found"
    }
  end

  defp render_status(400, _template, assigns) do
    %{
      status: "error",
      code: 400,
      message: Map.get(assigns, :message, "Bad request"),
      errors: Map.get(assigns, :errors, nil)
    }
  end

  defp render_status(401, _template, _assigns) do
    %{
      status: "error",
      code: 401,
      message: "Unauthorized"
    }
  end

  defp render_status(403, _template, _assigns) do
    %{
      status: "error",
      code: 403,
      message: "Forbidden"
    }
  end

  defp render_status(422, _template, assigns) do
    %{
      status: "error",
      code: 422,
      message: "Unprocessable entity",
      errors: Map.get(assigns, :errors, nil)
    }
  end

  defp render_status(500, _template, assigns) do
    %{
      status: "error",
      code: 500,
      message: Map.get(assigns, :message, "Internal server error")
    }
  end

  defp render_status(_code, _template, assigns) do
    %{
      status: "error",
      code: Map.get(assigns, :status, 500),
      message: Map.get(assigns, :message, "An error occurred")
    }
  end
end
