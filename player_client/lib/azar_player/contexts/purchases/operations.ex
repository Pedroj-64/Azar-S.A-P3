defmodule AzarPlayer.Contexts.Purchases.Operations do
  @moduledoc """
  Operaciones públicas de negocio para Compras de jugadores.

  Maneja la lógica compleja de:
  - Crear compras de billetes (completos o fracciones)
  - Validar disponibilidad de billetes
  - Calcular precios y descuentos
  - Procesar devoluciones y reembolsos
  - Consultar historial de compras
  - Verificar estado de compras (ganador, pérdida, etc)

  Integración:
  - Usa validaciones de AzarShared.Validations
  - Persiste en JSON con AzarShared.JsonHelper
  - Calcula valores con AzarShared.Calculations
  - Registra auditoría vía Audit.Operations
  - Integra con Draws.Operations para validar sorteos
  """

  alias AzarPlayer.Contexts.Purchases.Purchase
  alias AzarPlayer.Contexts.Purchases.Schemas.{Refund, Transaction, PriceBreakdown}
  alias AzarShared.{Validations, Calculations, JsonHelper, Constants}

  # ============================================================================
  # COMPRAS - Operaciones Principales
  # ============================================================================

  @doc """
  Crea una nueva compra de billete (completo o fracción).

  Parámetros:
  - user_id: ID del jugador que compra
  - user_name: Nombre del jugador
  - draw_id: ID del sorteo
  - draw_name: Nombre del sorteo
  - purchase_type: "complete" (billete completo) o "fraction" (fracción)
  - ticket_number: Número del billete (001-999)
  - fraction_number: Número de fracción (si es tipo "fraction")

  Validaciones:
  - El jugador existe y está activo
  - El sorteo existe y está abierto
  - El billete existe y está disponible
  - El jugador tiene saldo suficiente
  - El billete no está ya comprado

  Retorna:
  - {:ok, purchase} si la compra fue exitosa
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Deduce dinero de la cuenta del jugador
  - Marca el billete/fracción como vendido
  - Registra la transacción
  - Registra auditoría
  """
  @spec create_purchase(map()) :: {:ok, Purchase.t()} | {:error, term()}
  def create_purchase(attrs) do
    # Validación -> Cálculo de precio -> Persistencia -> Auditoría
    # Ver implementación en operations/operations.ex
  end

  @doc """
  Lista todas las compras de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - Lista de compras del jugador
  """
  @spec list_user_purchases(String.t()) :: [Purchase.t()]
  def list_user_purchases(user_id) do
    # Implementación delegada
  end

  @doc """
  Obtiene una compra específica por su ID.

  Parámetros:
  - purchase_id: ID de la compra

  Retorna:
  - {:ok, purchase} si existe
  - {:error, :not_found} si no existe
  """
  @spec get_purchase(String.t()) :: {:ok, Purchase.t()} | {:error, term()}
  def get_purchase(purchase_id) do
    # Implementación delegada
  end

  @doc """
  Lista compras de un jugador en un sorteo específico.

  Parámetros:
  - user_id: ID del jugador
  - draw_id: ID del sorteo

  Retorna:
  - Lista de compras del jugador en ese sorteo
  """
  @spec list_purchases_by_draw(String.t(), String.t()) :: [Purchase.t()]
  def list_purchases_by_draw(user_id, draw_id) do
    # Implementación delegada
  end

  # ============================================================================
  # DEVOLUCIONES - Gestión de Reembolsos
  # ============================================================================

  @doc """
  Devuelve una compra previamente realizada.

  Parámetros:
  - purchase_id: ID de la compra a devolver
  - reason: Razón de la devolución (string descriptivo)

  Validaciones:
  - La compra existe
  - La compra está en estado "active" (no fue devuelta/ganadora)
  - El sorteo aún no ha sido ejecutado
  - No han pasado más de N días desde la compra

  Retorna:
  - {:ok, refund} si la devolución fue exitosa
  - {:error, reason} si no se puede devolver

  Efectos secundarios:
  - Devuelve el dinero a la cuenta del jugador
  - Marca el billete/fracción como disponible
  - Registra el reembolso
  - Actualiza estado de la compra a "returned"
  - Registra auditoría
  """
  @spec return_purchase(String.t(), String.t()) :: {:ok, Refund.t()} | {:error, term()}
  def return_purchase(purchase_id, reason) do
    # Implementación delegada
  end

  @doc """
  Obtiene el historial de devoluciones de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - Lista de reembolsos procesados
  """
  @spec list_refunds_by_user(String.t()) :: [Refund.t()]
  def list_refunds_by_user(user_id) do
    # Implementación delegada
  end

  # ============================================================================
  # PRECIOS Y CÁLCULOS
  # ============================================================================

  @doc """
  Calcula el precio desglosado de una compra.

  Parámetros:
  - draw_id: ID del sorteo
  - purchase_type: "complete" o "fraction"
  - quantity: Cantidad de billetes/fracciones a comprar

  Retorna:
  - {:ok, price_breakdown} con desglose de:
    * Precio base
    * Impuestos
    * Comisiones
    * Descuentos aplicados
    * Total final
  - {:error, reason} si hay error

  Nota: Esta operación es de cálculo solamente, no crea compra.
  """
  @spec calculate_purchase_price(String.t(), String.t(), integer()) ::
          {:ok, PriceBreakdown.t()} | {:error, term()}
  def calculate_purchase_price(draw_id, purchase_type, quantity) do
    # Implementación delegada
  end

  # ============================================================================
  # VALIDACIONES Y CONSULTAS DE DISPONIBILIDAD
  # ============================================================================

  @doc """
  Verifica si una compra específica es posible.

  Parámetros:
  - user_id: ID del jugador
  - draw_id: ID del sorteo
  - ticket_number: Número del billete
  - purchase_type: "complete" o "fraction"
  - fraction_number: Número de fracción (si aplica)

  Retorna:
  - {:ok, :available} si se puede comprar
  - {:error, :already_owned} si ya lo compró
  - {:error, :sold_out} si está vendido
  - {:error, :draw_closed} si el sorteo está cerrado
  - {:error, reason} para otros errores
  """
  @spec validate_purchase(String.t(), String.t(), String.t(), String.t(), integer() | nil) ::
          {:ok, :available} | {:error, term()}
  def validate_purchase(user_id, draw_id, ticket_number, purchase_type, fraction_number \\ nil) do
    # Implementación delegada
  end

  @doc """
  Consulta saldo disponible de un jugador para compras.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - {:ok, balance} monto disponible
  - {:error, reason} si el jugador no existe
  """
  @spec get_available_balance(String.t()) :: {:ok, number()} | {:error, term()}
  def get_available_balance(user_id) do
    # Implementación delegada
  end

  # ============================================================================
  # ESTADÍSTICAS Y REPORTES
  # ============================================================================

  @doc """
  Obtiene estadísticas de compras de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - Map con:
    * total_purchases: cantidad de compras realizadas
    * total_spent: dinero total gastado
    * total_won: dinero total ganado
    * active_purchases: compras sin resolver (activas)
    * returned_purchases: compras devueltas
    * winning_purchases: compras ganadoras
  """
  @spec get_purchase_statistics(String.t()) :: map()
  def get_purchase_statistics(user_id) do
    # Implementación delegada
  end

  @doc """
  Obtiene las compras ganadoras de un jugador.

  Parámetros:
  - user_id: ID del jugador

  Retorna:
  - Lista de compras con estado "won"
  """
  @spec list_winning_purchases(String.t()) :: [Purchase.t()]
  def list_winning_purchases(user_id) do
    # Implementación delegada
  end

  # ============================================================================
  # FUNCIONES PRIVADAS - Delegación a operations/operations.ex
  # ============================================================================

  # Estas funciones privadas delegan al módulo de implementación
  # mantienen la API pública limpia y delegando la lógica compleja
end
