defmodule AzarSa.Core.Servers.DrawServer do
  @moduledoc """
  Servidor OTP dedicado a un sorteo específico.

  Cada instancia gestiona un sorteo único: compra de tickets (completos y fracciones),
  premios, ejecución y persistencia en JSON.
  """

  use GenServer

  alias AzarSa.Core.Data.Store
  alias AzarSa.Core.Support.NotificationServer

  ## API Pública

  def start_link({draw_id, _name, _date, _ticket_price, _fractions, _total_tickets} = args) do
    GenServer.start_link(__MODULE__, args, name: via(draw_id))
  end

  # Compatibilidad: arrancar solo con draw_id (restaura desde JSON)
  def start_link(draw_id) when is_binary(draw_id) do
    GenServer.start_link(__MODULE__, draw_id, name: via(draw_id))
  end

  def get_draw(draw_id) do
    GenServer.call(via(draw_id), :get)
  end

  def buy_ticket(draw_id, client_id, number, fraction \\ :full) do
    GenServer.call(via(draw_id), {:buy, client_id, number, fraction})
  end

  def return_ticket(draw_id, client_id, number) do
    GenServer.call(via(draw_id), {:return, client_id, number})
  end

  def run_draw(draw_id) do
    GenServer.call(via(draw_id), :run)
  end

  def add_prize(draw_id, name, amount) do
    GenServer.call(via(draw_id), {:add_prize, name, amount})
  end

  def delete_prize(draw_id, prize_id) do
    GenServer.call(via(draw_id), {:delete_prize, prize_id})
  end

  def delete_draw(draw_id) do
    # Solo elimina si el sorteo existe y puede borrarse
    GenServer.call(via(draw_id), :delete)
  end

  def get_available_numbers(draw_id) do
    GenServer.call(via(draw_id), :available_numbers)
  end

  def get_clients(draw_id) do
    GenServer.call(via(draw_id), :get_clients)
  end

  def get_revenue(draw_id) do
    GenServer.call(via(draw_id), :get_revenue)
  end

  ## Callbacks

  @impl true
  def init({draw_id, name, date, ticket_price, fractions, total_tickets}) do
    # Si ya existe un JSON previo, lo cargamos; si no, creamos estado inicial con los parámetros dados
    state =
      case Store.read("draws/#{draw_id}.json") do
        [] ->
          %{
            id: draw_id,
            name: name,
            date: date,
            ticket_price: ticket_price,
            fractions: fractions,
            total_tickets: total_tickets,
            tickets: %{},
            prizes: [],
            status: :pending,
            winning_number: nil,
            result: nil,
            created_at: DateTime.utc_now() |> DateTime.to_string()
          }

        data ->
          map_to_state(data)
      end

    Store.write("draws/#{draw_id}.json", state_to_map(state))
    {:ok, state}
  end

  @impl true
  def init(draw_id) when is_binary(draw_id) do
    # Restaurar desde JSON (usada en reinicios del supervisor)
    state =
      case Store.read("draws/#{draw_id}.json") do
        [] ->
          %{
            id: draw_id,
            name: draw_id,
            date: nil,
            ticket_price: 0,
            fractions: 1,
            total_tickets: 1000,
            tickets: %{},
            prizes: [],
            status: :pending,
            winning_number: nil,
            result: nil,
            created_at: DateTime.utc_now() |> DateTime.to_string()
          }

        data ->
          map_to_state(data)
      end

    {:ok, state}
  end

  # Retorna el estado completo del sorteo
  @impl true
  def handle_call(:get, _from, state), do: {:reply, state, state}

  # Compra de ticket: valida estado, número y fracción
  @impl true
  def handle_call({:buy, client_id, number, fraction}, _from, state) do
    number_str = to_string(number)
    max_number = state.total_tickets - 1

    cond do
      state.status != :pending ->
        {:reply, {:error, :draw_already_executed}, state}

      not is_integer(number) or number < 0 or number > max_number ->
        {:reply, {:error, :invalid_number}, state}

      fraction == :full and full_number_taken?(state.tickets, number_str) ->
        {:reply, {:error, :number_taken}, state}

      is_integer(fraction) and fraction_taken?(state.tickets, number_str, fraction, state.fractions) ->
        {:reply, {:error, :fraction_taken}, state}

      true ->
        ticket_key = ticket_key(number_str, fraction)

        ticket_data = %{
          "client_id" => client_id,
          "number" => number_str,
          "fraction" => fraction_label(fraction),
          "bought_at" => DateTime.utc_now() |> DateTime.to_string()
        }

        new_tickets = Map.put(state.tickets, ticket_key, ticket_data)
        new_state = %{state | tickets: new_tickets}

        Store.write(file(state.id), state_to_map(new_state))
        {:reply, {:ok, %{number: number, fraction: fraction}}, new_state}
    end
  end

  # Devolución de ticket: solo si el sorteo no ha sido ejecutado
  @impl true
  def handle_call({:return, client_id, number}, _from, state) do
    if state.status != :pending do
      {:reply, {:error, :draw_already_executed}, state}
    else
      number_str = to_string(number)

      owned_keys =
        Enum.filter(state.tickets, fn {_key, ticket} ->
          ticket["client_id"] == client_id and ticket["number"] == number_str
        end)
        |> Enum.map(fn {key, _} -> key end)

      if owned_keys == [] do
        {:reply, {:error, :ticket_not_owned}, state}
      else
        new_tickets = Map.drop(state.tickets, owned_keys)
        new_state = %{state | tickets: new_tickets}
        Store.write(file(state.id), state_to_map(new_state))
        {:reply, :ok, new_state}
      end
    end
  end

  # Ejecuta el sorteo: elige ganador aleatorio y notifica
  @impl true
  def handle_call(:run, _from, state) do
    cond do
      state.status == :done ->
        {:reply, {:error, :draw_already_executed}, state}

      map_size(state.tickets) == 0 ->
        {:reply, {:error, :no_tickets_sold}, state}

      true ->
        # Obtener números únicos vendidos para el sorteo
        sold_numbers =
          state.tickets
          |> Map.values()
          |> Enum.map(fn t -> t["number"] end)
          |> Enum.uniq()

        winner_number = Enum.random(sold_numbers)

        # Encontrar el cliente con la fracción ganadora (o billete completo)
        winner_ticket =
          state.tickets
          |> Map.values()
          |> Enum.find(fn t -> t["number"] == winner_number end)

        winner_client = winner_ticket["client_id"]

        total_prize =
          Enum.reduce(state.prizes, 0, fn p, acc ->
            amount = if is_map(p), do: p["amount"] || Map.get(p, :amount, 0), else: 0
            acc + amount
          end)

        result = %{
          "winner_number" => winner_number,
          "winner_client_id" => winner_client,
          "total_prize" => total_prize,
          "drawn_at" => DateTime.utc_now() |> DateTime.to_string()
        }

        NotificationServer.notify(winner_client, %{
          event: :draw_winner,
          draw_id: state.id,
          draw_name: state.name,
          number: winner_number,
          prize: total_prize
        })

        new_state = %{state | status: :done, winning_number: winner_number, result: result}
        Store.write(file(state.id), state_to_map(new_state))

        {:reply, {:ok, result}, new_state}
    end
  end

  # Agrega un premio: solo si el sorteo está pendiente
  @impl true
  def handle_call({:add_prize, name, amount}, _from, state) do
    if state.status != :pending do
      {:reply, {:error, :draw_already_executed}, state}
    else
      prize = %{
        "id" => :crypto.strong_rand_bytes(4) |> Base.encode16(),
        "name" => name,
        "amount" => amount,
        "created_at" => DateTime.utc_now() |> DateTime.to_string()
      }

      new_state = %{state | prizes: [prize | state.prizes]}
      Store.write(file(state.id), state_to_map(new_state))

      {:reply, {:ok, prize}, new_state}
    end
  end

  # Elimina un premio: solo si no hay tickets vendidos
  @impl true
  def handle_call({:delete_prize, prize_id}, _from, state) do
    cond do
      map_size(state.tickets) > 0 ->
        {:reply, {:error, :draw_has_tickets}, state}

      not Enum.any?(state.prizes, fn p ->
        Map.get(p, "id") == prize_id or Map.get(p, :id) == prize_id
      end) ->
        {:reply, {:error, :prize_not_found}, state}

      true ->
        new_prizes =
          Enum.reject(state.prizes, fn p ->
            Map.get(p, "id") == prize_id or Map.get(p, :id) == prize_id
          end)

        new_state = %{state | prizes: new_prizes}
        Store.write(file(state.id), state_to_map(new_state))
        {:reply, :ok, new_state}
    end
  end

  # Verifica si el sorteo puede eliminarse (sin premios)
  @impl true
  def handle_call(:delete, _from, state) do
    if length(state.prizes) > 0 do
      {:reply, {:error, :draw_has_prizes}, state}
    else
      Store.delete(file(state.id))
      {:reply, :ok, state}
    end
  end

  # Retorna números disponibles (completos y por fracción)
  @impl true
  def handle_call(:available_numbers, _from, state) do
    all_numbers = Enum.map(0..(state.total_tickets - 1), &to_string/1)

    available =
      Enum.reduce(all_numbers, %{full: [], fractions: %{}}, fn num, acc ->
        if full_number_taken?(state.tickets, num) do
          acc
        else
          available_fracs =
            Enum.reject(1..state.fractions, fn frac ->
              fraction_taken?(state.tickets, num, frac, state.fractions)
            end)

          acc
          |> Map.update!(:full, fn list ->
            if available_fracs == Enum.to_list(1..state.fractions), do: [num | list], else: list
          end)
          |> put_in([:fractions, num], available_fracs)
        end
      end)

    {:reply, {:ok, available}, state}
  end

  # Retorna la lista de clientes del sorteo, agrupados por tipo de compra
  @impl true
  def handle_call(:get_clients, _from, state) do
    {full_buyers, fraction_buyers} =
      state.tickets
      |> Map.values()
      |> Enum.reduce({[], []}, fn ticket, {full, fracs} ->
        case ticket["fraction"] do
          "full" -> {[ticket["client_id"] | full], fracs}
          _ -> {full, [ticket["client_id"] | fracs]}
        end
      end)

    result = %{
      full_buyers: full_buyers |> Enum.uniq() |> Enum.sort(),
      fraction_buyers: fraction_buyers |> Enum.uniq() |> Enum.sort()
    }

    {:reply, {:ok, result}, state}
  end

  # Retorna ingresos del sorteo (tickets vendidos * precio por fracción)
  @impl true
  def handle_call(:get_revenue, _from, state) do
    fraction_price = div(state.ticket_price, max(state.fractions, 1))
    revenue = map_size(state.tickets) * fraction_price
    {:reply, {:ok, revenue}, state}
  end

  ## Helpers privados

  defp via(draw_id) do
    {:via, Registry, {AzarSa.DrawRegistry, draw_id}}
  end

  defp file(draw_id), do: "draws/#{draw_id}.json"

  # Clave única del ticket: "number_full" o "number_1", "number_2", etc.
  defp ticket_key(number_str, :full), do: "#{number_str}_full"
  defp ticket_key(number_str, fraction), do: "#{number_str}_#{fraction}"

  defp fraction_label(:full), do: "full"
  defp fraction_label(n), do: to_string(n)

  # Verifica si el número completo ya está vendido (alguna fracción vendida o billete completo)
  defp full_number_taken?(tickets, number_str) do
    Map.has_key?(tickets, "#{number_str}_full") or
      Enum.any?(tickets, fn {key, _} -> String.starts_with?(key, "#{number_str}_") end)
  end

  # Verifica si una fracción específica de un número ya fue vendida
  defp fraction_taken?(tickets, number_str, fraction, _total_fractions) do
    Map.has_key?(tickets, "#{number_str}_full") or
      Map.has_key?(tickets, "#{number_str}_#{fraction}")
  end

  defp state_to_map(state) do
    %{
      "id" => state.id,
      "name" => state.name,
      "date" => state.date,
      "ticket_price" => state.ticket_price,
      "fractions" => state.fractions,
      "total_tickets" => state.total_tickets,
      "tickets" => state.tickets,
      "prizes" => state.prizes,
      "status" => state.status,
      "winning_number" => state.winning_number,
      "result" => state.result,
      "created_at" => state.created_at
    }
  end

  defp map_to_state(map) do
    %{
      id: map["id"],
      name: map["name"] || map["id"],
      date: map["date"],
      ticket_price: map["ticket_price"] || 0,
      fractions: map["fractions"] || 1,
      total_tickets: map["total_tickets"] || 1000,
      tickets: map["tickets"] || %{},
      prizes: map["prizes"] || [],
      status: if(map["status"], do: String.to_existing_atom(map["status"]), else: :pending),
      winning_number: map["winning_number"],
      result: map["result"],
      created_at: map["created_at"] || DateTime.utc_now() |> DateTime.to_string()
    }
  end
end
