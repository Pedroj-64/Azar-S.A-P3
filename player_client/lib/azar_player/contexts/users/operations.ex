defmodule AzarPlayerClient.Contexts.Users.Operations do
  @moduledoc """
  Operaciones públicas de negocio para Usuarios Jugadores.

  Maneja la lógica compleja de:
  - Registro de nuevos jugadores
  - Autenticación y validación de credenciales
  - Gestión de perfil de jugador
  - Gestión de saldo y crédito
  - Actualización de información personal
  - Consulta de estadísticas del jugador
  - Gestión de estado de cuenta (activa, suspendida, etc)
  - Auditoría de cambios en el perfil

  Integración:
  - Usa validaciones de AzarShared.Validations
  - Usa hash de contraseñas de AzarShared.CryptoHelper
  - Persiste en JSON con AzarShared.JsonHelper
  - Registra auditoría vía Audit.Operations
  """

  alias AzarPlayerClient.Contexts.Users.PlayerUser
  alias AzarPlayerClient.Contexts.Users.Schemas.{Profile, Credentials, BalanceRecord}
  alias AzarShared.{Validations, CryptoHelper, JsonHelper}

  # ============================================================================
  # REGISTRO Y AUTENTICACIÓN
  # ============================================================================

  @doc """
  Registra un nuevo jugador en el sistema.

  Parámetros:
  - full_name: nombre completo del jugador
  - document_number: número de documento (único)
  - email: email del jugador (único)
  - phone: teléfono (opcional)
  - password: contraseña sin encriptar

  Validaciones:
  - El documento no esté registrado previamente
  - El email no esté registrado previamente
  - La contraseña cumpla requisitos de seguridad
  - Datos obligatorios presentes
  - Formato de email válido
  - Formato de documento válido

  Retorna:
  - {:ok, user} si el registro fue exitoso
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Crea nueva cuenta
  - Genera saldo inicial
  - Registra auditoría
  - Envía email de bienvenida (si aplica)
  """
  @spec register_player(map()) :: {:ok, PlayerUser.t()} | {:error, term()}
  def register_player(attrs) do
    # Validación -> Hash de contraseña -> Persistencia -> Auditoría
    # Ver implementación en operations/operations.ex
  end

  @doc """
  Autentica un jugador con sus credenciales.

  Parámetros:
  - document_number: número de documento
  - password: contraseña sin encriptar

  Retorna:
  - {:ok, user} si la autenticación fue exitosa
  - {:error, :unauthorized} si credenciales son incorrectas
  - {:error, :not_found} si el usuario no existe
  - {:error, :account_suspended} si la cuenta está suspendida

  Efectos secundarios:
  - Actualiza fecha de último login
  - Registra intento de login en auditoría
  """
  @spec authenticate(String.t(), String.t()) :: {:ok, PlayerUser.t()} | {:error, term()}
  def authenticate(document_number, password) do
    # Implementación delegada
  end

  @doc """
  Valida si un token/sesión es válido.

  Parámetros:
  - user_id: ID del jugador
  - token: token de sesión

  Retorna:
  - {:ok, user} si el token es válido
  - {:error, :invalid_token} si el token no es válido
  """
  @spec validate_session(String.t(), String.t()) :: {:ok, PlayerUser.t()} | {:error, term()}
  def validate_session(user_id, token) do
    # Implementación delegada
  end

  # ============================================================================
  # GESTIÓN DE PERFIL
  # ============================================================================

  @doc """
  Obtiene el perfil de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - {:ok, profile} con datos del perfil
  - {:error, :not_found} si el usuario no existe
  """
  @spec get_profile(String.t()) :: {:ok, Profile.t()} | {:error, term()}
  def get_profile(user_id) do
    # Implementación delegada
  end

  @doc """
  Actualiza información del perfil de un jugador.

  Parámetros:
  - user_id: ID del jugador
  - attrs: Map con campos a actualizar (email, phone, etc)

  Campos actualizables:
  - email (con validación de unicidad)
  - phone
  - Otros datos de contacto

  Campos NO actualizables:
  - document_number (es único e inmutable)
  - account_balance (se gestiona vía transacciones)
  - full_name (cambios requieren verificación)

  Retorna:
  - {:ok, user} si actualización fue exitosa
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Actualiza datos del usuario
  - Registra cambios en auditoría
  """
  @spec update_profile(String.t(), map()) :: {:ok, PlayerUser.t()} | {:error, term()}
  def update_profile(user_id, attrs) do
    # Implementación delegada
  end

  @doc """
  Cambia la contraseña de un jugador.

  Parámetros:
  - user_id: ID del jugador
  - old_password: contraseña actual sin encriptar
  - new_password: nueva contraseña sin encriptar

  Validaciones:
  - La contraseña actual es correcta
  - La nueva contraseña cumple requisitos de seguridad
  - Nueva contraseña es diferente de la actual

  Retorna:
  - {:ok} si el cambio fue exitoso
  - {:error, :invalid_password} si la contraseña actual es incorrecta
  - {:error, reason} para otros errores

  Efectos secundarios:
  - Actualiza hash de contraseña
  - Invalida todas las sesiones activas
  - Registra cambio en auditoría
  """
  @spec change_password(String.t(), String.t(), String.t()) :: {:ok} | {:error, term()}
  def change_password(user_id, old_password, new_password) do
    # Implementación delegada
  end

  # ============================================================================
  # GESTIÓN DE SALDO Y CRÉDITO
  # ============================================================================

  @doc """
  Obtiene el saldo actual de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - {:ok, balance} monto disponible
  - {:error, :not_found} si el usuario no existe
  """
  @spec get_balance(String.t()) :: {:ok, number()} | {:error, term()}
  def get_balance(user_id) do
    # Implementación delegada
  end

  @doc """
  Incrementa el saldo de un jugador (depósito/crédito).

  Parámetros:
  - user_id: ID del jugador
  - amount: monto a agregar
  - reason: razón del incremento ("deposit", "refund", "prize", etc)

  Retorna:
  - {:ok, new_balance} saldo después de incremento
  - {:error, reason} si hay error

  Efectos secundarios:
  - Actualiza saldo del jugador
  - Registra transacción
  - Registra auditoría
  """
  @spec credit_balance(String.t(), number(), String.t()) ::
          {:ok, number()} | {:error, term()}
  def credit_balance(user_id, amount, reason) do
    # Implementación delegada
  end

  @doc """
  Decrementa el saldo de un jugador (débito/compra).

  Parámetros:
  - user_id: ID del jugador
  - amount: monto a descontar
  - reason: razón del decremento ("purchase", "fee", etc)

  Validaciones:
  - El jugador tiene saldo suficiente
  - El monto es positivo

  Retorna:
  - {:ok, new_balance} saldo después de decremento
  - {:error, :insufficient_funds} si no hay saldo suficiente
  - {:error, reason} para otros errores

  Efectos secundarios:
  - Actualiza saldo del jugador
  - Registra transacción
  - Registra auditoría
  """
  @spec debit_balance(String.t(), number(), String.t()) ::
          {:ok, number()} | {:error, term()}
  def debit_balance(user_id, amount, reason) do
    # Implementación delegada
  end

  @doc """
  Obtiene el historial de transacciones de saldo de un jugador.

  Parámetros:
  - user_id: ID del jugador
  - limit: cantidad máxima de registros (default: 50)
  - offset: para paginación (default: 0)

  Retorna:
  - Lista de BalanceRecord con movimientos de saldo
  """
  @spec list_balance_history(String.t(), integer(), integer()) :: [BalanceRecord.t()]
  def list_balance_history(user_id, limit \\ 50, offset \\ 0) do
    # Implementación delegada
  end

  # ============================================================================
  # GESTIÓN DE ESTADO DE CUENTA
  # ============================================================================

  @doc """
  Obtiene el estado de una cuenta de jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - {:ok, status} estado actual ("active", "inactive", "suspended")
  - {:error, :not_found} si el usuario no existe
  """
  @spec get_account_status(String.t()) :: {:ok, String.t()} | {:error, term()}
  def get_account_status(user_id) do
    # Implementación delegada
  end

  @doc """
  Suspende la cuenta de un jugador.

  Parámetros:
  - user_id: ID del jugador
  - reason: razón de la suspensión

  Retorna:
  - {:ok} si la suspensión fue exitosa
  - {:error, reason} si hay error

  Efectos secundarios:
  - Marca cuenta como "suspended"
  - Invalida sesiones activas
  - Registra auditoría
  - Envía notificación al jugador
  """
  @spec suspend_account(String.t(), String.t()) :: {:ok} | {:error, term()}
  def suspend_account(user_id, reason) do
    # Implementación delegada
  end

  @doc """
  Reactiva la cuenta de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - {:ok} si la reactivación fue exitosa
  - {:error, reason} si hay error
  """
  @spec reactivate_account(String.t()) :: {:ok} | {:error, term()}
  def reactivate_account(user_id) do
    # Implementación delegada
  end

  # ============================================================================
  # ESTADÍSTICAS Y REPORTES
  # ============================================================================

  @doc """
  Obtiene estadísticas de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - Map con:
    * total_spent: dinero total gastado
    * total_won: dinero total ganado
    * purchase_count: cantidad de compras
    * winning_count: cantidad de premios ganados
    * account_age_days: días desde registro
    * average_purchase_value: valor promedio de compra
  """
  @spec get_statistics(String.t()) :: map()
  def get_statistics(user_id) do
    # Implementación delegada
  end

  # ============================================================================
  # FUNCIONES PRIVADAS - Delegación a operations/operations.ex
  # ============================================================================

  # Estas funciones privadas delegan al módulo de implementación
end
