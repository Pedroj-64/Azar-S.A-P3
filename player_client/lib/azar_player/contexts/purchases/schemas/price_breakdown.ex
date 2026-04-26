defmodule AzarPlayer.Contexts.Purchases.Schemas.PriceBreakdown do
  @moduledoc """
  Struct que representa el Desglose de Precio de una compra.

  Desglosa cómo se calcula el precio final:
  - Precio base del billete/fracción
  - Impuestos aplicados
  - Comisiones del sistema
  - Descuentos aplicados
  - Total final
  """

  @enforce_keys [:base_price, :total_price]
  defstruct [
    :base_price,                  # Precio base (sin impuestos ni comisiones)
    :tax_amount,                  # Monto de impuestos
    :commission_amount,           # Monto de comisión del sistema
    :discount_amount,             # Monto descuentado (promociones, etc)
    :total_price,                 # Precio total final
    :currency,                    # Moneda (USD, COP, etc)
    :discount_reason,             # Razón del descuento
    :calculation_date             # Fecha del cálculo
  ]

  @type t :: %__MODULE__{
          base_price: number(),
          tax_amount: number(),
          commission_amount: number(),
          discount_amount: number(),
          total_price: number(),
          currency: String.t(),
          discount_reason: String.t() | nil,
          calculation_date: DateTime.t()
        }

  @doc """
  Crea un desglose de precio.
  """
  def new(attrs) do
    %__MODULE__{
      base_price: attrs[:base_price] || 0.0,
      tax_amount: attrs[:tax_amount] || 0.0,
      commission_amount: attrs[:commission_amount] || 0.0,
      discount_amount: attrs[:discount_amount] || 0.0,
      total_price: attrs[:total_price] || 0.0,
      currency: attrs[:currency] || "USD",
      discount_reason: attrs[:discount_reason],
      calculation_date: DateTime.utc_now()
    }
  end

  @doc """
  Calcula el total automáticamente.

  Fórmula: base + impuestos + comisión - descuento
  """
  def calculate_total(%__MODULE__{} = breakdown) do
    breakdown.base_price + breakdown.tax_amount + breakdown.commission_amount -
      breakdown.discount_amount
  end
end
