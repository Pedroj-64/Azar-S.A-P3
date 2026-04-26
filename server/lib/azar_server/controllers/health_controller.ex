defmodule AzarServer.HealthController do
  @moduledoc """
  Health check controller.

  Endpoint sin autenticación para verificar que el servidor está activo.
  """

  use Phoenix.Controller

  @doc """
  Health check endpoint.

  Retorna 200 OK si el servidor está activo.
  """
  def health(conn, _params) do
    json(conn, %{
      status: "ok",
      service: "Azar Server Central",
      timestamp: DateTime.utc_now(),
      version: "0.1.0"
    })
  end
end
