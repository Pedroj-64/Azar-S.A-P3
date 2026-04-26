defmodule AzarServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :azar_server,
      version: "0.1.0",
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      mod: {AzarServer.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      # Phoenix Framework
      {:phoenix, "~> 1.7"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_view, "~> 0.20"},
      {:phoenix_pubsub, "~> 2.1"},

      # Web
      {:plug_cowboy, "~> 2.6"},
      {:gettext, "~> 0.20"},

      # Data
      {:jason, "~> 1.4"},
      {:ecto, "~> 3.11"},

      # Security
      {:bcrypt_elixir, "~> 3.0"},
      {:guardian, "~> 2.3"},

      # Utilities
      {:elixir_uuid, "~> 1.2"},
      {:decimal, "~> 2.0"},

      # Shared Code
      {:azar_shared, path: "../shared_code"},

      # Development
      {:mix_test_watch, "~> 1.1", only: :dev},
      {:ex_doc, "~> 0.30", only: :dev}
    ]
  end

  defp aliases do
    [
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
