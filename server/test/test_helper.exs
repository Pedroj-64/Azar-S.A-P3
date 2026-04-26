ExUnit.start()

# Start the Azar Server application for tests
{:ok, _} = Application.ensure_all_started(:azar_server)

# Optional: Load any test fixtures or helpers
