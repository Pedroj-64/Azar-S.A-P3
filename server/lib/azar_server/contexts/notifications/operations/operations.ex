defmodule AzarServer.Contexts.Notifications.Operations do
  @moduledoc """
  Operaciones de notificaciones del sistema.

  Maneja:
  - Envío de notificaciones a usuarios
  - Almacenamiento en memoria (ETS) para acceso rápido
  - Historial de notificaciones en JSON
  - Broadcast de eventos en tiempo real vía WebSocket

  Tipos de notificaciones (via AzarShared.Schemas.Notification):
  - "purchase_confirmation": confirmación de compra de billete
  - "purchase_failed": error en compra de billete
  - "draw_executed": sorteo ejecutado
  - "draw_winner": usuario ganó
  - "draw_loser": usuario no ganó
  - "return_confirmation": confirmación de devolución
  - "admin_alert": alertas para administradores
  - "system_message": mensajes del sistema

  Las notificaciones se almacenan en:
  - Memoria (ETS) para acceso rápido durante sesión
  - JSON para persistencia histórica
  - Se envían via WebSocket para UI real-time
  """

  alias AzarShared.Schemas.Notification
  alias AzarShared.Utils.JsonHelper
  require Logger

  @notifications_file "priv/data/notifications.json"
  @notifications_table :notifications_table

  # Inicializar tabla ETS al cargar el módulo
  @on_load :init_notifications_table

  @doc """
  Inicializa la tabla ETS para almacenamiento en memoria de notificaciones.

  Se ejecuta automáticamente al cargar el módulo.
  """
  def init_notifications_table do
    if :ets.whereis(@notifications_table) == :undefined do
      :ets.new(@notifications_table, [:named_table, :bag, read_concurrency: true])
    end

    :ok
  end

  @doc """
  Crea y envía una notificación a un usuario.

  Parámetros:
  - user_id: ID del usuario receptor
  - type: tipo de notificación
  - title: título de la notificación
  - message: mensaje de la notificación

  Parámetros opcionales (via keyword list):
  - data: datos adicionales para la notificación (map)
  - priority: "low", "normal" (default), "high"
  - expires_in_hours: cuántas horas mantener la notificación (default: 24)
  - broadcast: ¿enviar via WebSocket? (default: true)

  Retorna:
  - {:ok, notification_id} si se envió correctamente
  - {:error, reason} si hay problema
  """
  @spec notify(String.t(), String.t(), String.t(), String.t(), keyword()) :: {:ok, String.t()} | {:error, String.t()}
  def notify(user_id, type, title, message, opts \\ []) do
    attrs = %{
      user_id: user_id,
      type: type,
      title: title,
      message: message,
      data: Keyword.get(opts, :data, %{}),
      priority: Keyword.get(opts, :priority, "normal"),
      expires_at: calculate_expiry(Keyword.get(opts, :expires_in_hours, 24))
    }

    case Notification.new(attrs) |> Notification.validate() do
      {:ok, notification} ->
        # Guardar en memoria (ETS)
        :ets.insert(@notifications_table, {user_id, notification})

        # Guardar en JSON para persistencia
        case JsonHelper.append_to_json_array(@notifications_file, notification) do
          :ok ->
            # Broadcast via WebSocket si está habilitado
            if Keyword.get(opts, :broadcast, true) do
              broadcast_notification(user_id, notification)
            end

            {:ok, notification.id}

          error ->
            Logger.error("Error al guardar notificación: #{inspect(error)}")
            error
        end

      error ->
        error
    end
  end

  @doc """
  Obtiene todas las notificaciones no leídas de un usuario.

  Retorna lista de notificaciones ordenadas por prioridad y fecha.
  """
  @spec unread_notifications(String.t()) :: {:ok, [Notification.t()]} | {:error, String.t()}
  def unread_notifications(user_id) do
    case get_user_notifications(user_id) do
      {:ok, notifications} ->
        unread =
          notifications
          |> Enum.filter(&(&1.read == false))
          |> Enum.filter(&(not Notification.expired?(&1)))
          |> Enum.sort_by(&sort_by_priority_and_date/1)

        {:ok, unread}

      error ->
        error
    end
  end

  @doc """
  Obtiene todas las notificaciones de un usuario (leídas y no leídas).

  Parámetros opcionales:
  - limit: cantidad máxima (default: todos)
  - offset: saltar N notificaciones (default: 0)
  - unread_only: solo no leídas (default: false)

  Retorna lista ordenada por fecha descendente.
  """
  @spec get_user_notifications(String.t(), keyword()) :: {:ok, [Notification.t()]} | {:error, String.t()}
  def get_user_notifications(user_id, opts \\ []) do
    case JsonHelper.read_json(@notifications_file) do
      {:ok, notifications} ->
        filtered =
          notifications
          |> Enum.filter(&(&1["user_id"] == user_id))
          |> Enum.filter(&notification_not_expired?/1)
          |> filter_unread_only(Keyword.get(opts, :unread_only, false))
          |> Enum.sort_by(fn n ->
            DateTime.to_unix(n["created_at"] || DateTime.utc_now())
          end, :desc)
          |> apply_limit_offset(opts)
          |> Enum.map(&to_notification/1)

        {:ok, filtered}

      error ->
        error
    end
  end

  @doc """
  Marca una notificación como leída.

  Actualiza tanto en memoria (ETS) como en JSON.
  """
  @spec mark_as_read(String.t(), String.t()) :: {:ok, Notification.t()} | {:error, String.t()}
  def mark_as_read(notification_id, user_id) do
    case get_notification(notification_id) do
      {:ok, notification} ->
        updated = Notification.mark_as_read(notification)

        # Actualizar en ETS
        :ets.delete(@notifications_table, {user_id, notification})
        :ets.insert(@notifications_table, {user_id, updated})

        # Actualizar en JSON
        case JsonHelper.update_json_key(@notifications_file, notification_id, updated) do
          :ok -> {:ok, updated}
          error -> error
        end

      error ->
        error
    end
  end

  @doc """
  Marca todas las notificaciones no leídas de un usuario como leídas.

  Retorna cantidad de notificaciones actualizadas.
  """
  @spec mark_all_as_read(String.t()) :: {:ok, integer()} | {:error, String.t()}
  def mark_all_as_read(user_id) do
    with {:ok, notifications} <- get_user_notifications(user_id) do
      read_count =
        notifications
        |> Enum.filter(&(&1.read == false))
        |> Enum.map(fn notification ->
          mark_as_read(notification.id, user_id)
        end)
        |> Enum.count()

      {:ok, read_count}
    end
  end

  @doc """
  Obtiene una notificación específica por ID.

  Retorna:
  - {:ok, notification} si existe
  - {:error, reason} si no existe o hay problema
  """
  @spec get_notification(String.t()) :: {:ok, Notification.t()} | {:error, String.t()}
  def get_notification(notification_id) do
    case JsonHelper.get_from_json(@notifications_file, notification_id) do
      {:ok, notification_data} ->
        {:ok, to_notification(notification_data)}

      error ->
        error
    end
  end

  @doc """
  Elimina una notificación.

  Solo permite eliminar notificaciones propias del usuario.
  """
  @spec delete_notification(String.t(), String.t()) :: {:ok, Notification.t()} | {:error, String.t()}
  def delete_notification(notification_id, user_id) do
    with {:ok, notification} <- get_notification(notification_id),
         :ok <- validate_notification_owner(notification, user_id),
         :ok <- JsonHelper.update_json_key(@notifications_file, notification_id, nil) do
      {:ok, notification}
    else
      error -> error
    end
  end

  @doc """
  Limpia notificaciones expiradas.

  Retorna cantidad de notificaciones eliminadas.
  """
  @spec cleanup_expired() :: {:ok, integer()} | {:error, String.t()}
  def cleanup_expired do
    case JsonHelper.read_json(@notifications_file) do
      {:ok, notifications} ->
        {expired, remaining} =
          Enum.split_with(notifications, fn notification ->
            not notification_not_expired?(notification)
          end)

        case File.write(@notifications_file, Jason.encode!(remaining, pretty: true)) do
          :ok ->
            # Limpiar también de ETS
            Enum.each(expired, fn notification ->
              :ets.delete(@notifications_table, {notification["user_id"], notification})
            end)

            {:ok, length(expired)}

          error ->
            error
        end

      error ->
        error
    end
  end

  @doc """
  Envía una notificación de compra exitosa.
  """
  @spec notify_purchase_success(String.t(), String.t(), String.t(), map()) :: {:ok, String.t()} | {:error, String.t()}
  def notify_purchase_success(user_id, user_name, ticket_type, data) do
    title = "Compra Exitosa"

    message =
      if ticket_type == "complete" do
        "Compraste un billete completo exitosamente."
      else
        "Compraste una fracción de billete exitosamente."
      end

    notify(user_id, "purchase_confirmation", title, message,
      data: Map.put(data, :user_name, user_name),
      priority: "high"
    )
  end

  @doc """
  Envía notificación de error en compra.
  """
  @spec notify_purchase_failed(String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def notify_purchase_failed(user_id, user_name, reason) do
    notify(user_id, "purchase_failed", "Error en la Compra", reason,
      data: %{user_name: user_name},
      priority: "high"
    )
  end

  @doc """
  Envía notificación a todos los usuarios de un sorteo sobre su ejecución.
  """
  @spec notify_draw_executed(String.t(), String.t(), [String.t()]) :: {:ok, integer()} | {:error, String.t()}
  def notify_draw_executed(draw_id, draw_name, winning_numbers) do
    # Obtener todos los usuarios que compraron billetes en este sorteo
    # Por ahora, retorna :ok con count 0 ya que requeriría acceso a lista de usuarios
    # Esta función sería llamada desde un contexto de usuarios
    Logger.info("Notificando ejecución del sorteo: #{draw_name}")
    {:ok, 0}
  end

  @doc """
  Envía notificación a ganador.
  """
  @spec notify_winner(String.t(), String.t(), String.t(), String.t(), number()) :: {:ok, String.t()} | {:error, String.t()}
  def notify_winner(user_id, user_name, draw_name, ticket_number, prize_amount) do
    notify(user_id, "draw_winner", "¡Ganaste!", "Felicidades #{user_name}, ganaste en el sorteo #{draw_name} con el billete #{ticket_number}",
      data: %{
        draw_name: draw_name,
        ticket_number: ticket_number,
        prize_amount: prize_amount
      },
      priority: "high",
      expires_in_hours: 720
    )
  end

  @doc """
  Envía notificación a perdedor (opcional, para sorteos de resultado).
  """
  @spec notify_loser(String.t(), String.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, String.t()}
  def notify_loser(user_id, user_name, draw_name, ticket_number) do
    notify(user_id, "draw_loser", "No ganaste", "Lamentablemente, tu billete #{ticket_number} no fue seleccionado en el sorteo #{draw_name}.",
      data: %{
        draw_name: draw_name,
        ticket_number: ticket_number
      },
      priority: "normal",
      expires_in_hours: 168
    )
  end

  @doc """
  Envía alerta a administradores.
  """
  @spec alert_admins(String.t(), String.t(), map()) :: {:ok, integer()} | {:error, String.t()}
  def alert_admins(alert_type, message, data \\ %{}) do
    # Aquí iría lógica para obtener lista de admins
    # Por ahora retorna count 0
    Logger.warn("Alerta a administradores [#{alert_type}]: #{message}")
    {:ok, 0}
  end

  # ============================================================================
  # HELPERS PRIVADOS
  # ============================================================================

  defp broadcast_notification(user_id, notification) do
    # Aquí iría integración con Phoenix.PubSub para WebSocket
    # Por ahora solo registra
    Logger.debug("Broadcasting notificación a #{user_id}: #{notification.type}")
  end

  defp calculate_expiry(hours) do
    DateTime.add(DateTime.utc_now(), hours * 3600)
  end

  defp notification_not_expired?(notification) do
    expires_at = notification["expires_at"] || DateTime.utc_now()
    DateTime.compare(DateTime.utc_now(), expires_at) == :lt
  end

  defp sort_by_priority_and_date(notification) do
    priority_value =
      case notification.priority do
        "high" -> 0
        "normal" -> 1
        "low" -> 2
        _ -> 1
      end

    {priority_value, DateTime.to_unix(notification.created_at) * -1}
  end

  defp filter_unread_only(notifications, true) do
    Enum.filter(notifications, &(&1["read"] == false))
  end

  defp filter_unread_only(notifications, false) do
    notifications
  end

  defp apply_limit_offset(notifications, opts) do
    limit = Keyword.get(opts, :limit, nil)
    offset = Keyword.get(opts, :offset, 0)

    notifications = Enum.drop(notifications, offset)

    if limit do
      Enum.take(notifications, limit)
    else
      notifications
    end
  end

  defp to_notification(notification_data) do
    Notification.new(notification_data)
  end

  defp validate_notification_owner(notification, user_id) do
    if notification.user_id == user_id do
      :ok
    else
      {:error, "No autorizado para eliminar esta notificación"}
    end
  end
end
