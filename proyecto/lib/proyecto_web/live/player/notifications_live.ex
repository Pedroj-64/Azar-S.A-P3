defmodule ProyectoWeb.Player.NotificationsLive do
  @moduledoc """
  Centro de notificaciones en tiempo real.
  Se suscribe a PubSub para recibir notificaciones al instante.
  Muestra fecha y hora legible de cada notificación.
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

    {:ok, assign(socket,
      page_title: gettext("notifications_title"),
      notifications: notifications
    )}
  end

  @impl true
  def handle_info({:new_notification, notif}, socket) do
    {:noreply, update(socket, :notifications, &[notif | &1])}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title={gettext("notifications_title")} subtitle={gettext("notifications_subtitle")} />

      <.glass_card>
        <div :if={@notifications == []}>
          <.empty_state icon_name="hero-bell-slash" message={gettext("notifications_empty")} />
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
                <div class="flex items-center gap-2 mt-1.5">
                  <.icon name="hero-clock" class="w-3 h-3 text-[var(--crema-oscura)]" />
                  <p class="font-mono text-[0.6rem] text-[var(--crema-oscura)] uppercase tracking-widest">
                    {format_datetime(notif.date)}
                  </p>
                </div>
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
    gettext("notification_winner", draw: name, number: num, prize: fmt(prize))
  end
  defp format_message(%{event: event}), do: gettext("notification_event", event: event)
  defp format_message(msg) when is_binary(msg), do: msg
  defp format_message(msg), do: inspect(msg)

  # Format the UTC datetime string into a human-readable format
  defp format_datetime(nil), do: "—"
  defp format_datetime(date_str) when is_binary(date_str) do
    case DateTime.from_iso8601(date_str) do
      {:ok, dt, _} ->
        # Format: "16 May 2026 · 19:08:36"
        month_names = %{1 => "Ene", 2 => "Feb", 3 => "Mar", 4 => "Abr", 5 => "May", 6 => "Jun",
                        7 => "Jul", 8 => "Ago", 9 => "Sep", 10 => "Oct", 11 => "Nov", 12 => "Dic"}
        month = Map.get(month_names, dt.month, "?")
        "#{dt.day} #{month} #{dt.year} · #{String.pad_leading(to_string(dt.hour), 2, "0")}:#{String.pad_leading(to_string(dt.minute), 2, "0")}:#{String.pad_leading(to_string(dt.second), 2, "0")}"
      _ ->
        # Fallback: try to show at least part of the string
        String.slice(date_str, 0, 19)
    end
  end
  defp format_datetime(_), do: "—"
end
