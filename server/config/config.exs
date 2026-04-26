# Configuration for Azar Server - Shared Configuration
#
# This configuration applies to all environments unless explicitly overridden.

import Config

# Configure the Endpoint
config :azar_server, AzarServer.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: AzarServer.ErrorJSON],
    layout: false
  ],
  pubsub_server: AzarServer.PubSub,
  live_view: [signing_salt: "azar_server_salt_123"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id, :draw_id]

# Configure JSON encoder
config :jason,
  encode_undefined: :null

# Shared Code
config :azar_shared, env: Mix.env()

# Paths for JSON persistence
config :azar_server,
  json_data_path: "priv/data",
  audit_log_path: "priv/data/audit_logs.json",
  notifications_path: "priv/data/notifications.json"

# Server configuration
config :azar_server,
  server: true,
  http: [port: 4000],
  secret_key_base: "CHANGE_ME_IN_PROD_SET_IN_ENV"
