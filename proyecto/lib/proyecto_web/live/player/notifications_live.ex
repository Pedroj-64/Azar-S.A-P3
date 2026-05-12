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
            class="p-4 page-enter"
            style="border-radius: 2px; background: rgba(90,46,16,0.2); border: 1px solid rgba(212,160,23,0.08);">
            <div class="flex items-start gap-3">
              <div class={[
                "p-2 mt-0.5",
                notification_icon_bg(notif.message)
              ]} style="border-radius: 2px;">
                <.icon name={notification_icon(notif.message)} class="w-5 h-5" />
              </div>
              <div class="flex-1">
                <p class="text-[var(--crema)] text-sm">{format_message(notif.message)}</p>
                <p class="font-mono text-[0.6rem] text-[var(--crema-oscura)] mt-1 uppercase tracking-widest">{notif.date}</p>
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

  defp notification_icon_bg(%{event: :draw_winner}), do: "bg-[rgba(212,160,23,0.15)] text-[var(--mostaza)]"
  defp notification_icon_bg(_), do: "bg-[rgba(42,107,107,0.15)] text-[var(--teal-lt)]"

  defp format_message(%{event: :draw_winner, draw_name: name, number: num, prize: prize}) do
    "🎉 ¡Ganaste en #{name}! Número #{num} — Premio: $#{fmt(prize)}"
  end
  defp format_message(%{event: event}), do: "Evento: #{event}"
  defp format_message(msg) when is_binary(msg), do: msg
  defp format_message(msg), do: inspect(msg)
end
