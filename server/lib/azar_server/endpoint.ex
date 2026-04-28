defmodule AzarServer.Endpoint do
  @moduledoc """
  Phoenix Endpoint para el Servidor Central Azar.

  Configura:
  - Servidor HTTP (Cowboy)
  - Rutas y versioning de API
  - Seguridad (HTTPS, HSTS)
  - Logging y telemetría
  - WebSocket (Channels)
  """

  use Phoenix.Endpoint, otp_app: :azar_server

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_azar_server_key",
    signing_salt: "azar_server_salt_123",
    max_age: 24 * 60 * 60
  ]

  socket "/socket", AzarServer.UserSocket,
    websocket: [timeout: 45_000],
    longpoll: false

  # Serve static files from "priv/static" directory.
  #
  # FLUJO VISUAL:
  # 1. Edita archivos en: assets/ (CSS, JS, locales)
  # 2. Ejecuta: ./setup.sh (copia assets/ → priv/static/)
  # 3. Phoenix sirve desde: priv/static/ (a cliente)
  #
  # Archivos permitidos: css, js, locales, images, fonts, favicon, robots.txt
  plug Plug.Static,
    at: "/",
    from: :azar_server,
    gzip: false,
    only: ~w(css fonts images js locales favicon.ico robots.txt)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug {:check_origin, false}

  plug Plug.Session, @session_options
  plug AzarServer.Router
end
