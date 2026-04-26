# Configuration for Azar Server - Production Environment
#
# This configuration is loaded before starting or upgrading your application
# and is also included if you build a release with `mix release`.

import Config

# Force HTTPS, set session cookie secure flag and enable HSTS
config :azar_server, AzarServer.Endpoint,
  url: [scheme: "https", host: System.get_env("APP_HOST") || "localhost", port: 443],
  http: [
    ip: {0, 0, 0, 0},
    port: String.to_integer(System.get_env("PORT") || "8080")
  ],
  secret_key_base: System.get_env("SECRET_KEY_BASE") || raise("SECRET_KEY_BASE not set"),
  server: true,
  check_origin: false

# Production logger configuration
config :logger,
  level: :info,
  backends: [:console],
  console: [
    format: "[$level] $message [$metadata]\n",
    metadata: [:request_id, :user_id, :draw_id, :action]
  ]

# JSON data persistence paths
config :azar_server,
  env: :prod,
  json_data_path: System.get_env("DATA_PATH") || "/data",
  audit_log_path: System.get_env("DATA_PATH") || "/data" <> "/audit_logs.json",
  notifications_path: System.get_env("DATA_PATH") || "/data" <> "/notifications.json"

# Security in production
config :azar_server,
  disable_auth: false,
  session_timeout: 24 * 60 * 60
