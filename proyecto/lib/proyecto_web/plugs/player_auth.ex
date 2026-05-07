defmodule ProyectoWeb.Plugs.PlayerAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(_params, _session, socket) do
    case get_session(socket, :client_id) do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "Debes iniciar sesión")
         |> redirect(to: "/login")}

      client_id ->
        {:cont, assign(socket, :client_id, client_id)}
    end
  end
end
