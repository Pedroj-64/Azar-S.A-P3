defmodule ProyectoWeb.Router do
  use ProyectoWeb, :router

  import Phoenix.LiveView.Router

  @moduledoc """
  Router principal de la aplicación.

  Define:
  - Pipelines (browser, api)
  - Rutas de sesión HTTP (login/logout vía controller)
  - Rutas LiveView organizadas por contexto (default, admin, player)
  - Hooks de inicialización (locale, autenticación)
  - Rutas de desarrollo (LiveDashboard, mailbox preview)
  """

  # PIPELINES

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_live_flash)
    plug(:put_root_layout, html: {ProyectoWeb.Layouts, :root})
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(ProyectoWeb.Plugs.Locale)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  # RUTAS DE SESIÓN (HTTP clásico para manejar cookies)
  scope "/session", ProyectoWeb do
    pipe_through(:browser)

    post("/player", SessionController, :create_player)
    post("/admin", SessionController, :create_admin)
    post("/register", SessionController, :create_register)
    delete("/logout", SessionController, :delete)
  end

  # RUTAS PRINCIPALES
  scope "/", ProyectoWeb do
    pipe_through(:browser)

    # SESIÓN PÚBLICA
    live_session :default,
      on_mount: [ProyectoWeb.Hooks.LocaleHook] do
      live("/", PageLive.Home)
      live("/login", Player.LoginLive)
      live("/register", Player.RegisterLive)
      live("/admin/login", Admin.LoginLive)
    end

    # SESIÓN ADMIN
    live_session :admin,
      layout: {ProyectoWeb.Layouts, :admin_app},
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
    live_session :player,
      layout: {ProyectoWeb.Layouts, :player_app},
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
  if Application.compile_env(:proyecto, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through(:browser)
      live_dashboard("/dashboard", metrics: ProyectoWeb.Telemetry)
      forward("/mailbox", Plug.Swoosh.MailboxPreview)
    end
  end
end
