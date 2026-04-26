defmodule AzarServer.Application do
  @moduledoc """
  Aplicación principal del Servidor Central Azar.

  Supervisa:
  - Endpoint HTTP (Phoenix)
  - PubSub para comunicación entre procesos
  - Procesos de sorteos dinámicos
  - Gestión de notificaciones

  Estructura de Supervisión (OTP):
  ```
  AzarServer.Application (Supervisor)
  ├── Endpoint (HTTP)
  ├── PubSub (comunicación)
  ├── DrawSupervisor (sorteos dinámicos)
  └── ...
  ```
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # HTTP Endpoint
      AzarServer.Endpoint,

      # PubSub para WebSocket y comunicación entre procesos
      {Phoenix.PubSub, name: AzarServer.PubSub},

      # DrawSupervisor para gestión dinámica de sorteos
      # {AzarServer.DrawSupervisor, []},

      # Health check supervisor
      # {AzarServer.HealthCheck, []}
    ]

    opts = [strategy: :one_for_one, name: AzarServer.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AzarServer.Endpoint.config_change(changed, removed)
    :ok
  end
end
