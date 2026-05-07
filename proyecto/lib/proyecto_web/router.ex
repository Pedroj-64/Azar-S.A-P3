defmodule ProyectoWeb.Router do
  use ProyectoWeb, :router

  import Phoenix.LiveView.Router

  @moduledoc """
  Router principal de la aplicación.

  Define:
  - Pipelines (browser, api)
  - Rutas LiveView organizadas por contexto (default, admin, player)
  - Hooks de inicialización (locale, autenticación)
  - Rutas de desarrollo (LiveDashboard, mailbox preview)
  """

  # PIPELINES

  pipeline :browser do
    # Acepta únicamente HTML
    plug(:accepts, ["html"])

    # Manejo de sesión y flash messages
    plug(:fetch_session)
    plug(:fetch_live_flash)

    # Layout raíz para LiveView y controllers
    plug(:put_root_layout, html: {ProyectoWeb.Layouts, :root})

    # Seguridad
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)

    # Internacionalización (locale desde params o sesión)
    plug(ProyectoWeb.Plugs.Locale)
  end

  pipeline :api do
    # Pipeline preparado para endpoints JSON
    plug(:accepts, ["json"])
  end

  # RUTAS PRINCIPALES

  scope "/", ProyectoWeb do
    pipe_through(:browser)

    # SESIÓN GENERAL
    # Rutas públicas o sin autenticación fuerte
    # Se aplica únicamente el hook de locale
    live_session :default,
      on_mount: [ProyectoWeb.Hooks.LocaleHook] do
      # Página principal (implementada con LiveView)
      live("/", PageLive.Home)

      # Autenticación
      live("/login", Player.LoginLive)
      live("/admin/login", Admin.LoginLive)
    end

    # SESIÓN ADMIN

    # Requiere autenticación de administrador
    # El hook AdminAuth valida acceso antes de montar el LiveView
    live_session :admin,
      on_mount: [
        ProyectoWeb.Hooks.LocaleHook,
        ProyectoWeb.Plugs.AdminAuth
      ] do
      live("/admin", Admin.DashboardLive)
      live("/admin/draws", Admin.DrawsLive)
      live("/admin/clients", Admin.ClientsLive)
      live("/admin/date", Admin.DateLive)
      live("/admin/reports", Admin.ReportsLive)
    end

    # SESIÓN PLAYER
    # Requiere autenticación de usuario jugador
    live_session :player,
      on_mount: [
        ProyectoWeb.Hooks.LocaleHook,
        ProyectoWeb.Plugs.PlayerAuth
      ] do
      live("/player", Player.DashboardLive)
      live("/player/draws", Player.DrawsLive)
      live("/player/draws/:id", Player.BuyTicketLive)
      live("/player/my-draws", Player.MyDrawsLive)
      live("/player/notifications", Player.NotificationsLive)
    end
  end

  # RUTAS DE DESARROLLO
  # Solo disponibles si :dev_routes está habilitado
  # No deben exponerse sin protección en producción
  if Application.compile_env(:proyecto, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)

      # Dashboard de métricas y telemetría
      live_dashboard("/dashboard", metrics: ProyectoWeb.Telemetry)

      # Vista previa de correos enviados
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
