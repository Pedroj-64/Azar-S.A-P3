defmodule AzarPlayerClient.Controllers.HealthController do
  @moduledoc """
  Health check controller para el cliente jugador.

  Endpoint sin autenticación para verificar que el servicio está activo.
  """

  use Phoenix.Controller

  @doc """
  Health check endpoint.

  Retorna 200 OK si el servidor está activo.
  """
  def health(conn, _params) do
    json(conn, %{
      status: "ok",
      service: "Azar Player Client",
      timestamp: DateTime.utc_now(),
      version: "0.1.0"
    })
  end
end
