defmodule AzarShared.Schemas.Notification do
  @moduledoc """
  Schema que representa una Notificación en el sistema.

  Una notificación es un mensaje transversal que se envía a usuarios
  para informar sobre eventos del sistema:
  - Compras de billetes/fracciones
  - Resultados de sorteos
  - Cambios en cuenta
  - Alertas administrativas

  Se usa en los 3 clientes (server, admin_client, player_client).
  Almacenamiento:
  - Memoria (ETS) para acceso rápido durante sesión
  - JSON para persistencia histórica
  - WebSocket para entrega real-time

  Tipos de notificación:
  - "purchase_confirmation": compra exitosa
  - "purchase_failed": error en compra
  - "draw_executed": sorteo ejecutado
  - "draw_winner": usuario ganó
  - "draw_loser": usuario no ganó
  - "return_confirmation": devolución exitosa
  - "admin_alert": alerta para administradores
  - "system_message": mensaje del sistema
  """

  @enforce_keys [:id, :user_id, :type, :title, :message]
  defstruct [
    :id,                          # UUID único de la notificación
    :user_id,                     # ID del usuario receptor
    :type,                        # Tipo de notificación (ver @doc)
    :title,                       # Título legible
    :message,                     # Contenido del mensaje
    :data,                        # Datos adicionales (map)
    :priority,                    # "low", "normal", "high"
    :created_at,                  # Fecha de creación
    :read,                        # ¿Fue leída?
    :read_at,                     # Cuándo se leyó
    :expires_at,                  # Cuándo expira
    :remarks                       # Observaciones
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          user_id: String.t(),
          type: String.t(),
          title: String.t(),
          message: String.t(),
          data: map() | nil,
          priority: String.t(),
          created_at: DateTime.t(),
          read: boolean(),
          read_at: DateTime.t() | nil,
          expires_at: DateTime.t() | nil,
          remarks: String.t() | nil
        }

  @doc """
  Crea una nueva notificación.

  Parámetros requeridos:
  - user_id: ID del usuario receptor
  - type: tipo de notificación
  - title: título del mensaje
  - message: contenido principal

  Parámetros opcionales (via attrs):
  - data: datos adicionales (map)
  - priority: "low", "normal" (default), "high"
  - read: false (default)
  - expires_at: fecha de expiración

  Ejemplo:
    Notification.new(%{
      user_id: "user-123",
      type: "purchase_confirmation",
      title: "Compra Exitosa",
      message: "Compraste un billete exitosamente",
      priority: "high"
    })
  """
  @spec new(map()) :: t()
  def new(attrs) do
    now = DateTime.utc_now()
    expires_at = DateTime.add(now, 24 * 3600)  # 24 horas por defecto

    %__MODULE__{
      id: attrs[:id] || generate_id(),
      user_id: attrs[:user_id],
      type: attrs[:type],
      title: attrs[:title],
      message: attrs[:message],
      data: attrs[:data] || %{},
      priority: attrs[:priority] || "normal",
      created_at: now,
      read: attrs[:read] || false,
      read_at: attrs[:read_at],
      expires_at: attrs[:expires_at] || expires_at,
      remarks: attrs[:remarks]
    }
  end

  @doc """
  Valida que la notificación tenga datos consistentes.

  Retorna:
  - {:ok, notification} si es válida
  - {:error, reason} si hay problema
  """
  @spec validate(t()) :: {:ok, t()} | {:error, String.t()}
  def validate(notification) do
    with :ok <- validate_required_fields(notification),
         :ok <- validate_priority(notification),
         :ok <- validate_dates(notification),
         :ok <- validate_message_length(notification) do
      {:ok, notification}
    else
      error -> error
    end
  end

  @doc """
  Marca la notificación como leída.

  Retorna struct actualizado.
  """
  @spec mark_as_read(t()) :: t()
  def mark_as_read(notification) do
    %{notification | read: true, read_at: DateTime.utc_now()}
  end

  @doc """
  Marca la notificación como no leída.

  Retorna struct actualizado.
  """
  @spec mark_as_unread(t()) :: t()
  def mark_as_unread(notification) do
    %{notification | read: false, read_at: nil}
  end

  @doc """
  Verifica si la notificación ha expirado.

  Retorna true si expiró, false si aún es válida.
  """
  @spec expired?(t()) :: boolean()
  def expired?(notification) do
    if notification.expires_at do
      DateTime.compare(DateTime.utc_now(), notification.expires_at) == :gt
    else
      false
    end
  end

  @doc """
  Obtiene etiqueta legible para el tipo de notificación.

  Retorna string en español.
  """
  @spec type_label(String.t()) :: String.t()
  def type_label("purchase_confirmation"), do: "Compra Confirmada"
  def type_label("purchase_failed"), do: "Error en Compra"
  def type_label("draw_executed"), do: "Sorteo Ejecutado"
  def type_label("draw_winner"), do: "¡Ganaste!"
  def type_label("draw_loser"), do: "No Ganaste"
  def type_label("return_confirmation"), do: "Devolución Confirmada"
  def type_label("admin_alert"), do: "Alerta Administrativa"
  def type_label("system_message"), do: "Mensaje del Sistema"
  def type_label(type), do: type

  @doc """
  Obtiene etiqueta legible para la prioridad.

  Retorna string en español.
  """
  @spec priority_label(String.t()) :: String.t()
  def priority_label("low"), do: "Baja"
  def priority_label("normal"), do: "Normal"
  def priority_label("high"), do: "Alta"
  def priority_label(priority), do: priority

  defp generate_id do
    UUID.uuid4()
  end

  defp validate_required_fields(notification) do
    if String.length(notification.user_id) > 0 and
       String.length(notification.type) > 0 and
       String.length(notification.title) > 0 and
       String.length(notification.message) > 0 do
      :ok
    else
      {:error, "Campos requeridos: user_id, type, title, message"}
    end
  end

  defp validate_priority(notification) do
    valid_priorities = ["low", "normal", "high"]

    if Enum.member?(valid_priorities, notification.priority) do
      :ok
    else
      {:error, "Prioridad inválida. Debe ser: low, normal, high"}
    end
  end

  defp validate_dates(notification) do
    if notification.expires_at and notification.read_at do
      if DateTime.compare(notification.read_at, notification.expires_at) == :lt do
        :ok
      else
        {:error, "Fecha de lectura no puede ser después de expiración"}
      end
    else
      :ok
    end
  end

  defp validate_message_length(notification) do
    if String.length(notification.message) > 0 and String.length(notification.message) <= 1000 do
      :ok
    else
      {:error, "Mensaje debe tener entre 1 y 1000 caracteres"}
    end
  end
end
