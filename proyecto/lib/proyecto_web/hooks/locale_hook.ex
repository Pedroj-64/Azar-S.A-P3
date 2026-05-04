defmodule ProyectoWeb.Hooks.LocaleHook do
  @moduledoc """
  LiveView `on_mount` hook that reads the locale from the HTTP session
  and applies it to the LiveView process via `Gettext.put_locale/2`.

  LiveView runs in a separate process from the HTTP request, so the
  locale set by the `Locale` plug does NOT carry over automatically.
  This hook bridges that gap.

  ## Usage in router.ex

      live_session :default, on_mount: [ProyectoWeb.Hooks.LocaleHook] do
        live "/sorteos", SorteosLive
        ...
      end

  ## Or in a LiveView directly

      on_mount {ProyectoWeb.Hooks.LocaleHook, :default}
  """

  import Phoenix.Component, only: [assign: 3]

  @default_locale "es"

  def on_mount(:default, _params, session, socket) do
    locale = Map.get(session, "locale", @default_locale)
    Gettext.put_locale(ProyectoWeb.Gettext, locale)

    socket = assign(socket, :locale, locale)
    {:cont, socket}
  end
end
