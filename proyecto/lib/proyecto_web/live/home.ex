defmodule ProyectoWeb.PageLive.Home do
  use ProyectoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
