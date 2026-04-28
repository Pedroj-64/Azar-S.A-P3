defmodule AzarServer.Views.NotificationJSON do
  @moduledoc """
  JSON view para respuestas de Notificaciones.

  Proporciona funciones para formatear datos de notificaciones
  en respuestas JSON consistentes.
  """

  def index(%{notifications: notifications}) do
    %{
      status: "ok",
      data: Enum.map(notifications, &notification_data/1)
    }
  end

  def show(%{notification: notification}) do
    %{
      status: "ok",
      data: notification_data(notification)
    }
  end

  def mark_read(%{notification: notification}) do
    %{
      status: "ok",
      message: "Notification marked as read",
      data: notification_data(notification)
    }
  end

  defp notification_data(notification) do
    %{
      id: notification.id,
      user_id: notification.user_id,
      notification_type: notification.notification_type,
      title: notification.title,
      message: notification.message,
      read: notification.read,
      created_at: notification.created_at,
      read_at: notification.read_at
    }
  end
end
