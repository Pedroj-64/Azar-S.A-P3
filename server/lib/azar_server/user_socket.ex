defmodule AzarServer.UserSocket do
  @moduledoc """
  WebSocket Socket para comunicación real-time.

  Maneja:
  - Conexión de usuarios
  - Suscripción a canales
  - Broadcasting de eventos
  """

  use Phoenix.Socket

  # A socket dispatch tags the requests by the kind of transport and the origin in order to help you do targeted, priority based load shedding.
  channel "draws:*", AzarServer.DrawChannel
  channel "notifications:*", AzarServer.NotificationChannel
  channel "tickets:*", AzarServer.TicketChannel

  @impl true
  def connect(params, socket, _connect_info) do
    # Aquí iría validación de token/autenticación
    user_id = params["user_id"]

    if user_id do
      {:ok, assign(socket, :user_id, user_id)}
    else
      :error
    end
  end

  @impl true
  def id(socket), do: "user:#{socket.assigns.user_id}"
end
