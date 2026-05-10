defmodule ProyectoWeb.SessionController do
  @moduledoc """
  Controlador HTTP para manejar sesiones.
  LiveView no puede escribir en la sesión HTTP directamente,
  por lo que usamos POST clásico para login y DELETE para logout.
  """
  use ProyectoWeb, :controller

  alias AzarSa.Core.Servers.CentralServer

  def create_player(conn, %{"document" => doc, "password" => pass}) do
    case CentralServer.authenticate_client(doc, pass) do
      {:ok, client} ->
        conn
        |> put_session(:client_id, client["id"])
        |> put_session(:client_name, client["name"])
        |> redirect(to: ~p"/player")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Documento o contraseña inválidos")
        |> redirect(to: ~p"/login")
    end
  end

  def create_admin(conn, %{"username" => user, "password" => pass}) do
    case CentralServer.authenticate_admin(user, pass) do
      {:ok, admin} ->
        conn
        |> put_session(:admin_id, admin["id"])
        |> put_session(:admin_username, admin["username"])
        |> redirect(to: ~p"/admin")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Usuario o contraseña inválidos")
        |> redirect(to: ~p"/admin/login")
    end
  end

  def create_register(conn, %{"name" => name, "document" => doc, "password" => pass, "card" => card}) do
    case CentralServer.register_client(name, doc, pass, card) do
      {:ok, client} ->
        conn
        |> put_session(:client_id, client.id)
        |> put_session(:client_name, client.name)
        |> put_flash(:info, "¡Registro exitoso! Bienvenido a Azar S.A.")
        |> redirect(to: ~p"/player")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "El documento ya está registrado")
        |> redirect(to: ~p"/register")
    end
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "Sesión cerrada correctamente")
    |> redirect(to: ~p"/")
  end
end
