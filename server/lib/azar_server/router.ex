defmodule AzarServer.Router do
  @moduledoc """
  Router principal del Servidor Central Azar.

  Define rutas para:
  - /api/health - health check
  - /api/draws - gestión de sorteos
  - /api/tickets - billetes
  - /api/fractions - fracciones
  - /api/prizes - premios
  - /api/audit - auditoría
  - /api/reports - reportes
  """

  use Phoenix.Router

  import Plug.Conn
  import Phoenix.Controller

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # Health check route (sin autenticación)
  scope "/api", AzarServer do
    pipe_through :api
    get "/health", HealthController, :health
  end

  # API Routes - v1
  scope "/api/v1", AzarServer do
    pipe_through :api

    # Draws Management
    resources "/draws", DrawController do
      post "/generate-tickets", DrawController, :generate_tickets
      post "/execute", DrawController, :execute
      post "/cancel", DrawController, :cancel
    end

    # Tickets
    scope "/draws/:draw_id" do
      post "/tickets/buy", TicketController, :buy_complete
      get "/tickets", TicketController, :index
      post "/tickets/:ticket_id/return", TicketController, :return
    end

    # Fractions
    scope "/draws/:draw_id" do
      post "/fractions/buy", FractionController, :buy
      get "/fractions", FractionController, :index
      post "/fractions/:fraction_id/return", FractionController, :return
    end

    # Prizes
    scope "/draws/:draw_id" do
      resources "/prizes", PrizeController, only: [:create, :index, :delete]
    end

    # Audit Logs
    get "/audit", AuditController, :index
    get "/audit/entity/:entity_type/:entity_id", AuditController, :entity_history
    get "/audit/user/:user_id", AuditController, :user_activity
    get "/audit/export", AuditController, :export

    # Reports
    get "/reports/income", ReportController, :income
    get "/reports/balance/:user_id", ReportController, :balance
    get "/reports/winners/:draw_id", ReportController, :winners

    # Notifications
    get "/users/:user_id/notifications", NotificationController, :index
    get "/notifications/:notification_id", NotificationController, :show
    post "/notifications/:notification_id/read", NotificationController, :mark_read
    post "/notifications/read-all/:user_id", NotificationController, :mark_all_read
    delete "/notifications/:notification_id", NotificationController, :delete
  end

  # Browser routes (si necesitas dashboard)
  scope "/", AzarServer do
    pipe_through :browser
    # get "/", PageController, :index
  end

  # Enable LiveDashboard in development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: AzarServer.Telemetry
    end
  end
end
