defmodule ProyectoWeb.Plugs.Locale do
  @moduledoc """
  Plug that reads the locale from query params or session and sets it
  for the current request process via `Gettext.put_locale/2`.

  ## Priority order
  1. `?locale=es` in the URL query string
  2. `:locale` stored in the session (from a previous request)
  3. Default: `"es"`

  ## Usage
  Add to your `:browser` pipeline in `router.ex`:

      plug ProyectoWeb.Plugs.Locale

  ## Changing locale from a form / link
  Send the user to `/?locale=en` (or any route with `?locale=en`).
  The plug will persist it to the session automatically.
  """

  import Plug.Conn

  @supported_locales ~w(en es)
  @default_locale "es"

  def init(opts), do: opts

  def call(conn, _opts) do
    locale =
      conn.params["locale"]
      |> valid_locale() ||
        get_session(conn, :locale)
        |> valid_locale() ||
        @default_locale

    conn
    |> put_session(:locale, locale)
    |> then(fn conn ->
      Gettext.put_locale(ProyectoWeb.Gettext, locale)
      conn
    end)
  end

  # Returns the locale if it's in the supported list, otherwise nil.
  defp valid_locale(nil), do: nil
  defp valid_locale(locale) when locale in @supported_locales, do: locale
  defp valid_locale(_), do: nil
end
