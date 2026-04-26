defmodule AzarServer.Controllers.NotificationController do
  @moduledoc """
  Controller para gestión de notificaciones.

  Proporciona endpoints para:
  - Enviar notificaciones a usuarios
  - Listar notificaciones de un usuario
  - Obtener detalles de una notificación
  - Marcar notificaciones como leídas
  - Eliminar notificaciones
  - Broadcast de eventos en tiempo real
  """

  use Phoenix.Controller

  alias AzarServer.Contexts.Notifications.Operations, as: NotificationOps

  @doc """
  Envía una notificación a un usuario.

  Parámetros esperados:
  - user_id: String
  - type: String ("purchase_confirmation", "draw_executed", "draw_winner", etc.)
  - title: String
  - message: String
  - data: Map (opcional, datos adicionales)
  - priority: String (opcional: "low", "normal", "high", default: "normal")

  Retorna:
  - 201 Created: Notificación enviada exitosamente
  - 400 Bad Request: Validación fallida
  """
  def send(conn, %{"notification" => notify_params}) do
    admin_id = conn.assigns[:current_user_id]

    case NotificationOps.notify(
      notify_params["user_id"],
      notify_params["type"],
      notify_params["title"],
      notify_params["message"],
      [
        data: notify_params["data"] || %{},
        priority: notify_params["priority"] || "normal",
        expires_in_hours: notify_params["expires_in_hours"] || 24,
        broadcast: notify_params["broadcast"] != false
      ]
    ) do
      {:ok, notification_id} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "ok",
          message: "Notification sent successfully",
          notification_id: notification_id
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista notificaciones de un usuario.

  Parámetros:
  - user_id: String (ID del usuario)
  - type: String (opcional: filtrar por tipo)
  - read: Boolean (opcional: filtrar leídas/no leídas)
  - page: Integer (default: 1)
  - limit: Integer (default: 30)

  Retorna:
  - 200 OK: Lista paginada de notificaciones
  """
  def list_user_notifications(conn, %{"user_id" => user_id} = params) do
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "30") |> min(100)

    filters = %{
      type: params["type"],
      read: parse_boolean(params["read"])
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{})

    case NotificationOps.get_user_notifications(user_id, filters) do
      {:ok, notifications} ->
        paginated = paginate_list(notifications, page, limit)

        json(conn, %{
          status: "ok",
          notifications: Enum.map(paginated, &format_notification_response/1),
          page: page,
          limit: limit,
          total: Enum.count(notifications),
          unread_count: Enum.count(notifications, fn n -> !n.read end)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene detalles de una notificación específica.

  Retorna:
  - 200 OK: Detalles de la notificación
  - 404 Not Found: Notificación no existe
  """
  def show(conn, %{"id" => notification_id}) do
    case NotificationOps.get_notification(notification_id) do
      {:ok, notification} ->
        json(conn, %{
          status: "ok",
          notification: format_notification_response(notification)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Marca una notificación como leída.

  Retorna:
  - 200 OK: Notificación marcada como leída
  - 404 Not Found: Notificación no existe
  """
  def mark_as_read(conn, %{"id" => notification_id}) do
    case NotificationOps.mark_as_read(notification_id) do
      {:ok, notification} ->
        json(conn, %{
          status: "ok",
          message: "Notification marked as read",
          notification: format_notification_response(notification)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Marca todas las notificaciones de un usuario como leídas.

  Retorna:
  - 200 OK: Operación completada
  """
  def mark_all_as_read(conn, %{"user_id" => user_id}) do
    case NotificationOps.mark_all_as_read(user_id) do
      :ok ->
        json(conn, %{
          status: "ok",
          message: "All notifications marked as read"
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Elimina una notificación.

  Retorna:
  - 200 OK: Notificación eliminada
  - 404 Not Found: Notificación no existe
  """
  def delete(conn, %{"id" => notification_id}) do
    user_id = conn.assigns[:current_user_id]

    case NotificationOps.delete_notification(notification_id, user_id) do
      :ok ->
        json(conn, %{
          status: "ok",
          message: "Notification deleted successfully"
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Elimina todas las notificaciones de un usuario.

  Retorna:
  - 200 OK: Operación completada
  """
  def delete_all(conn, %{"user_id" => user_id}) do
    case NotificationOps.delete_all_user_notifications(user_id) do
      :ok ->
        json(conn, %{
          status: "ok",
          message: "All notifications deleted successfully"
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene resumen de notificaciones de un usuario.

  Retorna:
  - Total de notificaciones
  - Cantidad de no leídas
  - Notificaciones por tipo
  - Notificaciones por prioridad
  """
  def summary(conn, %{"user_id" => user_id}) do
    case NotificationOps.get_user_notifications_summary(user_id) do
      {:ok, summary} ->
        json(conn, %{
          status: "ok",
          summary: summary
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Envía una notificación broadcast a múltiples usuarios.

  Parámetros:
  - user_ids: [String] (lista de IDs de usuarios)
  - type: String
  - title: String
  - message: String
  - data: Map (opcional)

  Retorna:
  - 201 Created: Notificaciones enviadas
  - 400 Bad Request: Validación fallida
  """
  def broadcast(conn, %{"broadcast" => broadcast_params}) do
    user_ids = broadcast_params["user_ids"] || []

    case NotificationOps.broadcast_notification(
      user_ids,
      broadcast_params["type"],
      broadcast_params["title"],
      broadcast_params["message"],
      broadcast_params["data"] || %{}
    ) do
      {:ok, count} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "ok",
          message: "Broadcast notification sent",
          recipients_count: count
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  # Helpers

  defp format_notification_response(notification) do
    %{
      id: notification.id,
      user_id: notification.user_id,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      data: notification.data,
      priority: notification.priority,
      read: notification.read,
      read_at: notification.read_at,
      created_at: notification.created_at,
      expires_at: notification.expires_at
    }
  end

  defp paginate_list(list, page, limit) when page > 0 and limit > 0 do
    offset = (page - 1) * limit
    list |> Enum.drop(offset) |> Enum.take(limit)
  end

  defp paginate_list(_list, _page, _limit), do: []

  defp parse_boolean("true"), do: true
  defp parse_boolean("false"), do: false
  defp parse_boolean(_), do: nil
end
