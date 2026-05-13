defmodule ProyectoWeb.Plugs.PlayerAuth do
  @moduledoc """
  Hook on_mount que protege las rutas de jugador.
  Verifica que exista :client_id en la sesión HTTP.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  use Gettext, backend: ProyectoWeb.Gettext

  def on_mount(:default, _params, session, socket) do
    case session["client_id"] do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, gettext("auth_player_required"))
         |> redirect(to: "/login")}

      client_id ->
        {:cont,
         socket
         |> assign(:client_id, client_id)
         |> assign(:client_name, session["client_name"])}
    end
  end
end
