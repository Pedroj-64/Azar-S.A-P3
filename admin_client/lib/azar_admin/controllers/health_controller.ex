defmodule AzarAdminClient.Controllers.HealthController do
  @moduledoc """
  Controller para verificar el estado de la aplicación.

  Proporciona endpoint:
  - GET /health - Verifica si la aplicación está funcionando
  """

  use Phoenix.Controller

  @doc """
  Verifica el estado de la aplicación.

  Retorna:
  - 200 OK: Aplicación funcionando correctamente
  """
  def health(conn, _params) do
    json(conn, %{
      status: "healthy",
      application: "AzarAdmin",
      timestamp: DateTime.utc_now(),
      version: "1.0.0"
    })
  end
end
