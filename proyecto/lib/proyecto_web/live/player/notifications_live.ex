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
            style={"border-radius: 2px; background: #{notif_bg(notif)}; border: 1px solid #{notif_border(notif)};"}>
            <div class="flex items-start gap-3">
              <div class={[
                "p-2 mt-0.5",
                notification_icon_bg(notif)
              ]} style="border-radius: 2px;">
                <.icon name={notification_icon(notif)} class="w-5 h-5" />
              </div>
              <div class="flex-1">
                <p class="text-[var(--crema)] text-sm">{format_message(notif)}</p>
                <div class="flex items-center gap-2 mt-1.5">
                  <.icon name="hero-clock" class="w-3 h-3 text-[var(--crema-oscura)]" />
                  <p class="font-mono text-[0.6rem] text-[var(--crema-oscura)] uppercase tracking-widest">
                    {format_datetime(get_date(notif))}
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

  # ── Helpers: safe access for atom or string keyed maps ──

  defp get_event(notif) do
    msg = notif[:message] || notif["message"] || notif
    msg[:event] || msg["event"]
  end

  defp get_date(notif) do
    notif[:date] || notif["date"]
  end

  defp get_msg(notif) do
    notif[:message] || notif["message"] || notif
  end

  # ── Icons ──

  defp notification_icon(notif) do
    case get_event(notif) do
      :draw_winner -> "hero-trophy"
      "draw_winner" -> "hero-trophy"
      :draw_completed -> "hero-flag"
      "draw_completed" -> "hero-flag"
      :ticket_purchased -> "hero-ticket"
      "ticket_purchased" -> "hero-ticket"
      :ticket_returned -> "hero-arrow-uturn-left"
      "ticket_returned" -> "hero-arrow-uturn-left"
      :new_draw -> "hero-sparkles"
      "new_draw" -> "hero-sparkles"
      _ -> "hero-bell"
    end
  end

  defp notification_icon_bg(notif) do
    case get_event(notif) do
      e when e in [:draw_winner, "draw_winner"] ->
        "bg-[rgba(212,160,23,0.15)] text-[var(--mostaza)]"
      e when e in [:draw_completed, "draw_completed"] ->
        "bg-[rgba(200,80,40,0.1)] text-[var(--crema-oscura)]"
      e when e in [:ticket_purchased, "ticket_purchased"] ->
        "bg-[rgba(42,107,107,0.15)] text-[var(--teal-lt)]"
      e when e in [:ticket_returned, "ticket_returned"] ->
        "bg-[rgba(200,80,40,0.15)] text-[var(--naranja)]"
      e when e in [:new_draw, "new_draw"] ->
        "bg-[rgba(212,160,23,0.1)] text-[var(--mostaza)]"
      _ ->
        "bg-[rgba(42,107,107,0.15)] text-[var(--teal-lt)]"
    end
  end

  defp notif_bg(notif) do
    case get_event(notif) do
      e when e in [:draw_winner, "draw_winner"] -> "rgba(212,160,23,0.06)"
      _ -> "rgba(90,46,16,0.2)"
    end
  end

  defp notif_border(notif) do
    case get_event(notif) do
      e when e in [:draw_winner, "draw_winner"] -> "rgba(212,160,23,0.15)"
      _ -> "rgba(212,160,23,0.08)"
    end
  end

  # ── Message formatting ──

  defp format_message(notif) do
    msg = get_msg(notif)
    event = msg[:event] || msg["event"]
    do_format(event, msg)
  end

  defp do_format(e, msg) when e in [:draw_winner, "draw_winner"] do
    name = msg[:draw_name] || msg["draw_name"] || "?"
    num = msg[:number] || msg["number"] || "?"
    prize = msg[:prize] || msg["prize"] || 0
    "🏆 ¡Ganaste en #{name}! Número #{num} — Premio: $#{fmt(prize)}"
  end

  defp do_format(e, msg) when e in [:ticket_purchased, "ticket_purchased"] do
    name = msg[:draw_name] || msg["draw_name"] || "?"
    num = msg[:number] || msg["number"] || "?"
    "🎫 Compraste ticket ##{num} en #{name}"
  end

  defp do_format(e, msg) when e in [:ticket_returned, "ticket_returned"] do
    name = msg[:draw_name] || msg["draw_name"] || "?"
    num = msg[:number] || msg["number"] || "?"
    "↩️ Devolviste ticket ##{num} en #{name}"
  end

  defp do_format(e, msg) when e in [:new_draw, "new_draw"] do
    name = msg[:draw_name] || msg["draw_name"] || "?"
    "✨ Nuevo sorteo disponible: #{name}"
  end

  defp do_format(e, msg) when e in [:draw_completed, "draw_completed"] do
    name = msg[:draw_name] || msg["draw_name"] || "?"
    nums = msg[:winning_numbers] || msg["winning_numbers"] || "?"
    "🎰 El sorteo #{name} ha finalizado. Números ganadores: ##{nums}. No ganaste esta vez — ¡suerte para la próxima!"
  end

  defp do_format(_event, msg) when is_binary(msg), do: msg
  defp do_format(event, _msg) when not is_nil(event), do: "Evento: #{event}"
  defp do_format(_, msg), do: inspect(msg)

  # ── Date formatting ──

  defp format_datetime(nil), do: "—"
  defp format_datetime(date_str) when is_binary(date_str) do
    case DateTime.from_iso8601(date_str) do
      {:ok, dt, _} ->
        month_names = %{1 => "Ene", 2 => "Feb", 3 => "Mar", 4 => "Abr", 5 => "May", 6 => "Jun",
                        7 => "Jul", 8 => "Ago", 9 => "Sep", 10 => "Oct", 11 => "Nov", 12 => "Dic"}
        month = Map.get(month_names, dt.month, "?")
        "#{dt.day} #{month} #{dt.year} · #{String.pad_leading(to_string(dt.hour), 2, "0")}:#{String.pad_leading(to_string(dt.minute), 2, "0")}:#{String.pad_leading(to_string(dt.second), 2, "0")}"
      _ ->
        String.slice(date_str, 0, 19)
    end
  end
  defp format_datetime(_), do: "—"
end
