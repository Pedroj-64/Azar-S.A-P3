defmodule ProyectoWeb.PageController do
  use ProyectoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
