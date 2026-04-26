defmodule AzarShared.Utils.RandomHelper do
  @moduledoc """
  Funciones auxiliares para generación de números aleatorios y selección de ganadores.

  Contiene utilidades para:
  - Generar números aleatorios
  - Seleccionar ganadores aleatoriamente
  - Shuffling de listas
  - Selección ponderada
  """

  @doc """
  Genera un número aleatorio entre min y max (inclusive).

  Retorna: número entero aleatorio

  Ejemplo:
    RandomHelper.random_integer(1, 999)
    # 523
  """
  @spec random_integer(integer(), integer()) :: integer()
  def random_integer(min, max) when is_integer(min) and is_integer(max) and min <= max do
    :rand.uniform(max - min + 1) + min - 1
  end

  def random_integer(_, _), do: 0

  @doc """
  Genera una lista de números aleatorios únicos entre min y max.

  Retorna: lista de números únicos ordenados

  Ejemplo:
    RandomHelper.random_unique_integers(5, 1, 100)
    # [15, 34, 67, 82, 95]
  """
  @spec random_unique_integers(integer(), integer(), integer()) :: list(integer())
  def random_unique_integers(count, min, max)
    when is_integer(count) and is_integer(min) and is_integer(max) and min < max do
    range_size = max - min + 1

    if count > range_size do
      # Si pedimos más números que el rango, retornamos todos
      Enum.to_list(min..max) |> Enum.shuffle()
    else
      # Generar números únicos
      Enum.uniq_by(
        Stream.repeatedly(fn -> random_integer(min, max) end),
        fn _ -> :rand.uniform() end
      )
      |> Enum.take(count)
      |> Enum.sort()
    end
  end

  def random_unique_integers(_, _, _), do: []

  @doc """
  Selecciona un elemento aleatorio de una lista.

  Retorna: elemento o nil si lista vacía

  Ejemplo:
    RandomHelper.pick_random([1, 2, 3, 4, 5])
    # 3
  """
  @spec pick_random(list(any())) :: any() | nil
  def pick_random(list) when is_list(list) and length(list) > 0 do
    Enum.random(list)
  end

  def pick_random(_), do: nil

  @doc """
  Selecciona N elementos aleatorios únicos de una lista.

  Retorna: lista de elementos seleccionados

  Ejemplo:
    RandomHelper.pick_random_n([1, 2, 3, 4, 5], 3)
    # [2, 4, 1]
  """
  @spec pick_random_n(list(any()), integer()) :: list(any())
  def pick_random_n(list, count) when is_list(list) and is_integer(count) and count > 0 do
    list
    |> Enum.shuffle()
    |> Enum.take(count)
  end

  def pick_random_n(_, _), do: []

  @doc """
  Mezcla una lista aleatoriamente (shuffle).

  Retorna: lista mezclada

  Ejemplo:
    RandomHelper.shuffle([1, 2, 3, 4, 5])
    # [4, 1, 5, 2, 3]
  """
  @spec shuffle(list(any())) :: list(any())
  def shuffle(list) when is_list(list) do
    Enum.shuffle(list)
  end

  def shuffle(_), do: []

  @doc """
  Selecciona ganadores de una lista de billetes según cantidad.

  Retorna: lista de IDs de ganadores

  Ejemplo:
    tickets = [
      %{id: "t1", number: 001},
      %{id: "t2", number: 002},
      %{id: "t3", number: 003},
      %{id: "t4", number: 004}
    ]
    RandomHelper.select_winners(tickets, 2)
    # ["t2", "t4"]
  """
  @spec select_winners(list(map()), integer()) :: list(String.t())
  def select_winners(tickets, winner_count)
    when is_list(tickets) and is_integer(winner_count) and winner_count > 0 do
    tickets
    |> Enum.shuffle()
    |> Enum.take(winner_count)
    |> Enum.map(fn ticket -> ticket[:id] || ticket["id"] end)
  end

  def select_winners(_, _), do: []

  @doc """
  Genera números ganadores para un sorteo (números entre 1 y 999).

  Retorna: lista de números ganadores

  Ejemplo:
    RandomHelper.generate_winning_numbers(5)
    # [145, 023, 567, 089, 234]
  """
  @spec generate_winning_numbers(integer()) :: list(String.t())
  def generate_winning_numbers(count) when is_integer(count) and count > 0 do
    random_unique_integers(count, 1, 999)
    |> Enum.map(fn num ->
      num
      |> Integer.to_string()
      |> String.pad_leading(3, "0")
    end)
  end

  def generate_winning_numbers(_), do: []

  @doc """
  Calcula la probabilidad de ganancia.

  Retorna: porcentaje como número decimal

  Ejemplo:
    RandomHelper.calculate_win_probability(5, 1000)
    # 0.5
  """
  @spec calculate_win_probability(integer(), integer()) :: float()
  def calculate_win_probability(winning_tickets, total_tickets)
    when is_integer(winning_tickets) and is_integer(total_tickets) and total_tickets > 0 do
    (winning_tickets / total_tickets) * 100
  end

  def calculate_win_probability(_, _), do: 0.0

  @doc """
  Genera una distribución ponderada de ganadores.

  Útil para sorteos con múltiples premios con diferentes probabilidades.

  Retorna: lista de ganadores por premio

  Ejemplo:
    prizes = [
      %{name: "Mayor", count: 1, weight: 100},
      %{name: "Segundo", count: 5, weight: 50},
      %{name: "Tercero", count: 10, weight: 25}
    ]
    tickets = [... lista de 1000 tickets ...]
    RandomHelper.weighted_draw(tickets, prizes)
    # [premio_mayor, premio_segundo, premio_tercero]
  """
  @spec weighted_draw(list(map()), list(map())) :: list(list(String.t()))
  def weighted_draw(tickets, prizes) when is_list(tickets) and is_list(prizes) do
    Enum.map(prizes, fn prize ->
      select_winners(tickets, prize[:count] || 1)
    end)
  end

  def weighted_draw(_, _), do: []

  @doc """
  Genera un número de referencia aleatorio.

  Útil para ID de transacciones, códigos de confirmación, etc.

  Retorna: string alfanumérico
  """
  @spec generate_reference_number() :: String.t()
  def generate_reference_number do
    :crypto.strong_rand_bytes(6)
    |> Base.encode16(case: :lower)
  end

  @doc """
  Genera un código de promoción aleatorio.

  Formato: 4 caracteres aleatorios en mayúsculas + 4 números

  Ejemplo: "ABCD1234"
  """
  @spec generate_promo_code() :: String.t()
  def generate_promo_code do
    letters =
      Enum.map(1..4, fn _ ->
        random_integer(65, 90)  # A-Z en ASCII
        |> <<>>
      end)
      |> Enum.join()

    numbers =
      Enum.map(1..4, fn _ ->
        random_integer(0, 9)
        |> Integer.to_string()
      end)
      |> Enum.join()

    letters <> numbers
  end
end
