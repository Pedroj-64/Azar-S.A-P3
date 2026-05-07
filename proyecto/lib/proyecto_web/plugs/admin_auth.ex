defmodule ProyectoWeb.Plugs.AdminAuth do
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(_params, _session, socket) do
    case get_session(socket, :admin_id) do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "Debes iniciar sesión como admin")
         |> redirect(to: "/admin/login")}

      admin_id ->
        {:cont, assign(socket, :admin_id, admin_id)}
    end
  end
end
