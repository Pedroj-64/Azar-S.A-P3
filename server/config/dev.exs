# Configuration for Azar Server - Development Environment
#
# Do not include metadata nor timestamps in development logs
# to keep the output clean and easy to read.

import Config

# Configure your database
config :azar_server,
  env: :dev,
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: []

# For development, we disable any cache and enable
# code reloading and debugging.
config :logger,
  level: :debug,
  backends: [:console],
  console: [
    format: "[$level] $message $metadata\n",
    metadata: [:request_id, :user_id]
  ]

# HTTP configuration for development
config :azar_server, AzarServer.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    # Node is not started yet, comment if it fails on your system
    # node: [
    #   "node_modules/webpack/bin/webpack.js",
    #   "--mode",
    #   "development",
    #   "--watch",
    #   cd: Path.expand("../assets", __DIR__)
    # ]
  ]

# Do not include metadata nor timestamps in development logs
# to keep the output clean and easy to read.
config :logger,
  format: "[$level] $message\n"
