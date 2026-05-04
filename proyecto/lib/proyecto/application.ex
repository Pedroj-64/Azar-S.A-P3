defmodule Proyecto.Application do
  @moduledoc """
  Punto de entrada de la aplicación OTP Azar S.A.

  Orden del árbol de supervisión:
  1. Infraestructura (Telemetry, PubSub, DNS)
  2. Registry de sorteos (debe existir antes que cualquier DrawServer)
  3. Bitácora (AuditLogger) — debe estar lista antes que el CentralServer para registrar todo
  4. Servidor de notificaciones
  5. Servidor de fecha del sistema (SystemDate)
  6. Supervisor dinámico de sorteos
  7. Servidor Central (fachada principal)
  8. Endpoint web (al último)
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ProyectoWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:proyecto, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Proyecto.PubSub},

      # 1. Registry: directorio de procesos de sorteos
      {Registry, keys: :unique, name: AzarSa.DrawRegistry},

      # 2. Bitácora: debe iniciarse antes que CentralServer para capturar todo
      AzarSa.Core.Support.AuditLogger,

      # 3. Notificaciones a jugadores
      AzarSa.Core.Support.NotificationServer,

      # 4. Fecha del sistema (permite avanzar fecha y ejecutar sorteos automáticamente)
      AzarSa.Core.Support.SystemDate,

      # 5. Supervisor dinámico de sorteos
      AzarSa.Core.Servers.DrawSupervisor,

      # 6. Servidor Central (fachada que orquesta todo)
      AzarSa.Core.Servers.CentralServer,

      # 7. Endpoint web
      ProyectoWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: Proyecto.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    ProyectoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
