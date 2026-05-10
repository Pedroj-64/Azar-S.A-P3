defmodule ProyectoWeb.Plugs.PlayerAuth do
  @moduledoc """
  Hook on_mount que protege las rutas de jugador.
  Verifica que exista :client_id en la sesión HTTP.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    case session["client_id"] do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "Debes iniciar sesión")
         |> redirect(to: "/login")}

      client_id ->
        {:cont,
         socket
         |> assign(:client_id, client_id)
         |> assign(:client_name, session["client_name"])}
    end
  end
end
