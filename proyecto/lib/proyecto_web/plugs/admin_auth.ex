defmodule ProyectoWeb.Plugs.AdminAuth do
  @moduledoc """
  Hook on_mount que protege las rutas de administrador.
  Verifica que exista :admin_id en la sesión HTTP.
  """
  import Phoenix.LiveView
  import Phoenix.Component

  def on_mount(:default, _params, session, socket) do
    case session["admin_id"] do
      nil ->
        {:halt,
         socket
         |> put_flash(:error, "Debes iniciar sesión como admin")
         |> redirect(to: "/admin/login")}

      admin_id ->
        {:cont,
         socket
         |> assign(:admin_id, admin_id)
         |> assign(:admin_username, session["admin_username"])}
    end
  end
end
