defmodule AzarShared.Utils.MoneyHelper do
  @moduledoc """
  Funciones auxiliares para manejo de dinero y cálculos financieros.

  Contiene utilidades para:
  - Formateo de moneda
  - Cálculos de balance
  - Conversiones monetarias
  - Porcentajes y descuentos
  """

  @doc """
  Formatea un número como moneda con símbolo.

  Retorna: string formateado (ej: "$1,234.56")

  Ejemplo:
    MoneyHelper.format_currency(1234.56)
    # "$1,234.56"
  """
  @spec format_currency(number()) :: String.t()
  def format_currency(amount) when is_number(amount) do
    formatted = :erlang.float_to_binary(amount, decimals: 2)
    "$#{formatted}"
  end

  def format_currency(_), do: "$0.00"

  @doc """
  Formatea un número como moneda sin símbolo.

  Retorna: string con 2 decimales (ej: "1,234.56")
  """
  @spec format_amount(number()) :: String.t()
  def format_amount(amount) when is_number(amount) do
    :erlang.float_to_binary(amount, decimals: 2)
  end

  def format_amount(_), do: "0.00"

  @doc """
  Calcula el balance personal de un usuario.

  Balance = total_ganado - total_gastado

  Retorna: {balance, total_spent, total_earned, percentage}
  """
  @spec calculate_balance(number(), number()) :: {number(), number(), number(), float()}
  def calculate_balance(total_spent, total_earned)
    when is_number(total_spent) and is_number(total_earned) do
    balance = total_earned - total_spent
    percentage =
      if total_spent > 0 do
        (total_earned / total_spent) * 100
      else
        0.0
      end

    {balance, total_spent, total_earned, percentage}
  end

  def calculate_balance(_, _), do: {0, 0, 0, 0.0}

  @doc """
  Calcula un descuento sobre un monto.

  Retorna: {monto_original, descuento, monto_final}

  Ejemplo:
    MoneyHelper.apply_discount(100, 10)
    # {100, 10.0, 90.0}
  """
  @spec apply_discount(number(), number()) :: {number(), number(), number()}
  def apply_discount(amount, discount_percent)
    when is_number(amount) and is_number(discount_percent) and discount_percent >= 0 and discount_percent <= 100 do
    discount = amount * (discount_percent / 100)
    final = amount - discount
    {amount, discount, final}
  end

  def apply_discount(amount, _), do: {amount, 0, amount}

  @doc """
  Calcula un monto más IVA/impuesto.

  Retorna: {monto_sin_impuesto, impuesto, monto_total}

  Ejemplo:
    MoneyHelper.apply_tax(100, 19)  # 19% de IVA
    # {100, 19.0, 119.0}
  """
  @spec apply_tax(number(), number()) :: {number(), number(), number()}
  def apply_tax(amount, tax_percent)
    when is_number(amount) and is_number(tax_percent) and tax_percent >= 0 do
    tax = amount * (tax_percent / 100)
    total = amount + tax
    {amount, tax, total}
  end

  def apply_tax(amount, _), do: {amount, 0, amount}

  @doc """
  Calcula el porcentaje de un monto.

  Retorna: porcentaje como número

  Ejemplo:
    MoneyHelper.calculate_percentage(100, 25)
    # 25.0
  """
  @spec calculate_percentage(number(), number()) :: number()
  def calculate_percentage(total, percent)
    when is_number(total) and is_number(percent) and total > 0 do
    total * (percent / 100)
  end

  def calculate_percentage(_, _), do: 0

  @doc """
  Calcula el retorno de inversión (ROI).

  ROI = ((ganancia - inversión) / inversión) * 100

  Retorna: porcentaje como número

  Ejemplo:
    MoneyHelper.calculate_roi(100, 150)  # inversión, ganancia
    # 50.0
  """
  @spec calculate_roi(number(), number()) :: number()
  def calculate_roi(investment, earnings)
    when is_number(investment) and is_number(earnings) and investment > 0 do
    ((earnings - investment) / investment) * 100
  end

  def calculate_roi(_, _), do: 0.0

  @doc """
  Valida si un monto es válido para transacción.

  Retorna: {:ok, amount} o {:error, String.t()}
  """
  @spec validate_transaction_amount(number()) :: {:ok, number()} | {:error, String.t()}
  def validate_transaction_amount(amount) when is_number(amount) do
    cond do
      amount <= 0 ->
        {:error, "El monto debe ser positivo"}

      amount > 1_000_000 ->
        {:error, "El monto excede el límite de transacción"}

      true ->
        {:ok, amount}
    end
  end

  def validate_transaction_amount(_), do: {:error, "El monto debe ser un número"}

  @doc """
  Redondea un monto a 2 decimales.

  Ejemplo:
    MoneyHelper.round_to_cents(10.567)
    # 10.57
  """
  @spec round_to_cents(number()) :: float()
  def round_to_cents(amount) when is_number(amount) do
    Float.round(amount, 2)
  end

  def round_to_cents(_), do: 0.0

  @doc """
  Convierte centavos a pesos/unidad monetaria.

  Ejemplo:
    MoneyHelper.cents_to_currency(1234)
    # 12.34
  """
  @spec cents_to_currency(integer()) :: float()
  def cents_to_currency(cents) when is_integer(cents) do
    cents / 100
  end

  def cents_to_currency(_), do: 0.0

  @doc """
  Convierte pesos/unidad monetaria a centavos.

  Ejemplo:
    MoneyHelper.currency_to_cents(12.34)
    # 1234
  """
  @spec currency_to_cents(number()) :: integer()
  def currency_to_cents(amount) when is_number(amount) do
    trunc(amount * 100)
  end

  def currency_to_cents(_), do: 0

  @doc """
  Calcula el promedio de un listado de montos.

  Retorna: promedio o 0 si lista vacía
  """
  @spec calculate_average(list(number())) :: number()
  def calculate_average(amounts) when is_list(amounts) and length(amounts) > 0 do
    total = Enum.sum(amounts)
    total / length(amounts)
  end

  def calculate_average(_), do: 0

  @doc """
  Suma una lista de montos.
  """
  @spec sum_amounts(list(number())) :: number()
  def sum_amounts(amounts) when is_list(amounts) do
    Enum.sum(amounts)
  end

  def sum_amounts(_), do: 0
end
