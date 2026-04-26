# Configuration for Azar Server - Test Environment
#
# Environment for running tests. Use in-memory persistence for speed.

import Config

# Test environment configuration
config :azar_server,
  env: :test,
  debug_errors: false,
  code_reloader: false,
  disable_auth: true

# HTTP endpoint for tests
config :azar_server, AzarServer.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  server: false

# Minimal logging during tests
config :logger,
  level: :warning,
  backends: [:console],
  console: [format: "[$level] $message\n"]
