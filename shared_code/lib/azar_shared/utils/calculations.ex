defmodule AzarShared.Utils.Calculations do
  @moduledoc """
  Cálculos reutilizables en todo el sistema.

  Contiene funciones para calcular:
  - Ingresos totales
  - Ganancias/pérdidas
  - Fracciones de billetes
  - Premios distribuidos
  """

  @doc """
  Calcula el ingreso total de un sorteo.

  Retorna la suma de todos los billetes vendidos (completos y fracciones).
  """
  @spec calculate_total_revenue(list(map())) :: number()
  def calculate_total_revenue(tickets) when is_list(tickets) do
    tickets
    |> Enum.map(fn ticket ->
      case ticket do
        %{purchase_price: price} when is_number(price) -> price
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def calculate_total_revenue(_), do: 0

  @doc """
  Calcula las ganancias netas (ingresos - premios pagados).

  Retorna ingresos - total_premios
  """
  @spec calculate_net_profit(number(), number()) :: number()
  def calculate_net_profit(revenue, total_prizes) when is_number(revenue) and is_number(total_prizes) do
    revenue - total_prizes
  end

  def calculate_net_profit(_, _), do: 0

  @doc """
  Calcula el precio de una fracción de billete.

  Divide el precio del billete completo entre cantidad de fracciones.
  """
  @spec calculate_fraction_price(number(), integer()) :: number()
  def calculate_fraction_price(full_ticket_value, fractions_count)
    when is_number(full_ticket_value) and is_integer(fractions_count) and fractions_count > 0 do
    full_ticket_value / fractions_count
  end

  def calculate_fraction_price(_, _), do: 0

  @doc """
  Calcula cuántos billetes de un número específico se vendieron.

  Cuenta billetes completos + todas las fracciones de ese número.
  """
  @spec count_sold_tickets(list(map()), String.t()) :: integer()
  def count_sold_tickets(tickets, ticket_number) when is_list(tickets) and is_binary(ticket_number) do
    tickets
    |> Enum.filter(fn ticket ->
      case ticket do
        %{number: num, status: status} when num == ticket_number and status != "returned" -> true
        _ -> false
      end
    end)
    |> Enum.count()
  end

  def count_sold_tickets(_, _), do: 0

  @doc """
  Calcula el ingreso promedio por billete vendido.

  Retorna ingresos_totales / billetes_vendidos
  """
  @spec calculate_average_ticket_price(number(), integer()) :: number()
  def calculate_average_ticket_price(total_revenue, tickets_sold)
    when is_number(total_revenue) and is_integer(tickets_sold) and tickets_sold > 0 do
    total_revenue / tickets_sold
  end

  def calculate_average_ticket_price(_, _), do: 0

  @doc """
  Calcula el total de premios distribuidos.

  Suma los valores de todos los premios que fueron entregados.
  """
  @spec calculate_total_prizes_distributed(list(map())) :: number()
  def calculate_total_prizes_distributed(prizes) when is_list(prizes) do
    prizes
    |> Enum.filter(fn prize ->
      case prize do
        %{status: "awarded"} -> true
        _ -> false
      end
    end)
    |> Enum.map(fn prize ->
      case prize do
        %{value: value} when is_number(value) -> value
        _ -> 0
      end
    end)
    |> Enum.sum()
  end

  def calculate_total_prizes_distributed(_), do: 0

  @doc """
  Calcula el porcentaje de retorno de billetes (devoluciones).

  Retorna (billetes_devueltos / billetes_totales) * 100
  """
  @spec calculate_return_percentage(integer(), integer()) :: float()
  def calculate_return_percentage(returned_tickets, total_tickets)
    when is_integer(returned_tickets) and is_integer(total_tickets) and total_tickets > 0 do
    (returned_tickets / total_tickets) * 100
  end

  def calculate_return_percentage(_, _), do: 0.0

  @doc """
  Calcula cuántas fracciones se pueden obtener de un billete.

  Es simplemente la cantidad de fracciones configuradas.
  """
  @spec calculate_fractions_per_ticket(integer()) :: integer()
  def calculate_fractions_per_ticket(fractions_count) when is_integer(fractions_count) and fractions_count > 0 do
    fractions_count
  end

  def calculate_fractions_per_ticket(_), do: 1

  @doc """
  Calcula el ingreso esperado si se venden todos los billetes.

  Retorna total_billetes * precio_unitario
  """
  @spec calculate_max_revenue(integer(), number()) :: number()
  def calculate_max_revenue(total_tickets, price_per_ticket)
    when is_integer(total_tickets) and is_number(price_per_ticket) do
    total_tickets * price_per_ticket
  end

  def calculate_max_revenue(_, _), do: 0
end
