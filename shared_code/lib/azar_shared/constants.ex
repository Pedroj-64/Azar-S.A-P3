defmodule AzarShared.Constants do
  @moduledoc """
  Constantes globales del sistema Azar.

  Define estados, tipos, códigos y límites usados en toda la aplicación.
  """

  # ============================================================================
  # ESTADOS DE SORTEO
  # ============================================================================

  @doc "Sorteo abierto para compras"
  def draw_status_open, do: "open"

  @doc "Sorteo ejecutado (resultado conocido)"
  def draw_status_executed, do: "executed"

  @doc "Sorteo cancelado"
  def draw_status_cancelled, do: "cancelled"

  @doc "Lista de todos los estados de sorteo válidos"
  def all_draw_statuses, do: ["open", "executed", "cancelled"]

  # ============================================================================
  # TIPOS DE BILLETES
  # ============================================================================

  @doc "Billete completo"
  def ticket_type_complete, do: "complete"

  @doc "Fracción de billete"
  def ticket_type_fraction, do: "fraction"

  @doc "Lista de todos los tipos de billete válidos"
  def all_ticket_types, do: ["complete", "fraction"]

  # ============================================================================
  # ESTADOS DE BILLETE
  # ============================================================================

  @doc "Billete activo y disponible"
  def ticket_status_active, do: "active"

  @doc "Billete devuelto"
  def ticket_status_returned, do: "returned"

  @doc "Billete ganador"
  def ticket_status_winner, do: "winner"

  @doc "Billete perdedor"
  def ticket_status_loser, do: "loser"

  @doc "Lista de todos los estados de billete válidos"
  def all_ticket_statuses, do: ["active", "returned", "winner", "loser"]

  # ============================================================================
  # ESTADOS DE PREMIO
  # ============================================================================

  @doc "Premio pendiente de entrega"
  def prize_status_pending, do: "pending"

  @doc "Premio entregado"
  def prize_status_awarded, do: "awarded"

  @doc "Premio cancelado"
  def prize_status_cancelled, do: "cancelled"

  @doc "Lista de todos los estados de premio válidos"
  def all_prize_statuses, do: ["pending", "awarded", "cancelled"]

  # ============================================================================
  # ROLES DE USUARIO
  # ============================================================================

  @doc "Rol administrador"
  def role_admin, do: "admin"

  @doc "Rol jugador"
  def role_player, do: "player"

  @doc "Rol sistema (procesos automáticos)"
  def role_system, do: "system"

  @doc "Lista de todos los roles válidos"
  def all_roles, do: ["admin", "player", "system"]

  # ============================================================================
  # ACCIONES DE AUDITORÍA
  # ============================================================================

  @doc "Acción crear"
  def audit_action_create, do: "create"

  @doc "Acción actualizar"
  def audit_action_update, do: "update"

  @doc "Acción eliminar"
  def audit_action_delete, do: "delete"

  @doc "Acción comprar"
  def audit_action_buy, do: "buy"

  @doc "Acción devolver"
  def audit_action_return, do: "return"

  @doc "Acción ejecutar"
  def audit_action_execute, do: "execute"

  @doc "Lista de todas las acciones válidas"
  def all_audit_actions, do: ["create", "update", "delete", "buy", "return", "execute"]

  # ============================================================================
  # TIPOS DE ENTIDAD
  # ============================================================================

  @doc "Entidad sorteo"
  def entity_type_draw, do: "draw"

  @doc "Entidad billete"
  def entity_type_ticket, do: "ticket"

  @doc "Entidad premio"
  def entity_type_prize, do: "prize"

  @doc "Entidad usuario"
  def entity_type_user, do: "user"

  @doc "Lista de todos los tipos de entidad válidos"
  def all_entity_types, do: ["draw", "ticket", "prize", "user"]

  # ============================================================================
  # LÍMITES Y RESTRICCIONES
  # ============================================================================

  @doc "Número mínimo de billete"
  def min_ticket_number, do: 1

  @doc "Número máximo de billete"
  def max_ticket_number, do: 999

  @doc "Fracciones mínimas por billete"
  def min_fractions, do: 2

  @doc "Fracciones máximas por billete"
  def max_fractions, do: 100

  @doc "Cantidad mínima de billetes por sorteo"
  def min_tickets_per_draw, do: 100

  @doc "Cantidad máxima de billetes por sorteo"
  def max_tickets_per_draw, do: 99999

  @doc "Monto mínimo permitido para transacciones"
  def min_transaction_amount, do: 1

  @doc "Monto máximo permitido para transacciones"
  def max_transaction_amount, do: 1_000_000

  # ============================================================================
  # RUTAS Y DIRECTORIOS
  # ============================================================================

  @doc "Directorio de datos JSON"
  def data_directory, do: "priv/data"

  @doc "Directorio de archivos estáticos"
  def static_directory, do: "priv/static"

  @doc "Archivo de sorteos"
  def draws_file, do: "draws.json"

  @doc "Archivo de usuarios"
  def users_file, do: "users.json"

  @doc "Archivo de auditoría"
  def audit_file, do: "audit.json"

  # ============================================================================
  # CANALES WEBSOCKET
  # ============================================================================

  @doc "Canal de notificaciones para jugadores"
  def channel_player_notifications, do: "player:notifications"

  @doc "Canal de actualizaciones de sorteos"
  def channel_draw_updates, do: "draw:updates"

  @doc "Canal de notificaciones para administradores"
  def channel_admin_notifications, do: "admin:notifications"

  # ============================================================================
  # CÓDIGOS DE ERROR
  # ============================================================================

  @doc "Recurso no encontrado"
  def error_not_found, do: "NOT_FOUND"

  @doc "Parámetros inválidos"
  def error_invalid_params, do: "INVALID_PARAMS"

  @doc "Operación no autorizada"
  def error_unauthorized, do: "UNAUTHORIZED"

  @doc "Recurso ya existe"
  def error_already_exists, do: "ALREADY_EXISTS"

  @doc "Error interno del servidor"
  def error_internal_error, do: "INTERNAL_ERROR"

  @doc "Fondos insuficientes"
  def error_insufficient_funds, do: "INSUFFICIENT_FUNDS"

  @doc "Sorteo no disponible"
  def error_draw_not_available, do: "DRAW_NOT_AVAILABLE"

  @doc "Billete no disponible"
  def error_ticket_not_available, do: "TICKET_NOT_AVAILABLE"
end
