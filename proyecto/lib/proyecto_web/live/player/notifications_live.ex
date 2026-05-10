defmodule ProyectoWeb.Player.NotificationsLive do
  @moduledoc """
  Centro de notificaciones en tiempo real.
  Se suscribe a PubSub para recibir notificaciones al instante.
  """
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Support.NotificationServer

  @impl true
  def mount(_params, _session, socket) do
    client_id = socket.assigns.client_id
    notifications = NotificationServer.get_notifications(client_id)

    if connected?(socket) do
      Phoenix.PubSub.subscribe(Proyecto.PubSub, "notifications:#{client_id}")
    end

    {:ok, assign(socket, page_title: "Notificaciones", notifications: notifications)}
  end

  @impl true
  def handle_info({:new_notification, notif}, socket) do
    {:noreply, update(socket, :notifications, &[notif | &1])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title="Notificaciones" subtitle="Mensajes y alertas del sistema" />

      <.glass_card>
        <div :if={@notifications == []}>
          <.empty_state icon_name="hero-bell-slash" message="No tienes notificaciones" />
        </div>

        <div class="space-y-3">
          <div :for={notif <- @notifications}
            class="p-4 rounded-xl bg-slate-700/30 border border-white/5 hover:border-white/10 transition-all animate-fade-in-up">
            <div class="flex items-start gap-3">
              <div class={[
                "p-2 rounded-lg mt-0.5",
                notification_icon_bg(notif.message)
              ]}>
                <.icon name={notification_icon(notif.message)} class="w-5 h-5" />
              </div>
              <div class="flex-1">
                <p class="text-white text-sm">{format_message(notif.message)}</p>
                <p class="text-slate-500 text-xs mt-1">{notif.date}</p>
              </div>
            </div>
          </div>
        </div>
      </.glass_card>
    </div>
    """
  end

  defp notification_icon(%{event: :draw_winner}), do: "hero-trophy"
  defp notification_icon(_), do: "hero-bell"

  defp notification_icon_bg(%{event: :draw_winner}), do: "bg-yellow-400/20 text-yellow-400"
  defp notification_icon_bg(_), do: "bg-blue-400/20 text-blue-400"

  defp format_message(%{event: :draw_winner, draw_name: name, number: num, prize: prize}) do
    "🎉 ¡Ganaste en #{name}! Número #{num} — Premio: $#{fmt(prize)}"
  end
  defp format_message(%{event: event}), do: "Evento: #{event}"
  defp format_message(msg) when is_binary(msg), do: msg
  defp format_message(msg), do: inspect(msg)

  defp fmt(n) when is_integer(n), do: n |> Integer.to_string() |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  defp fmt(_), do: "0"
end
