defmodule AzarServer.Contexts.Draws.Operations do
  @moduledoc """
  Operaciones de negocio para Sorteos.

  Maneja la lógica compleja de:
  - Crear sorteos
  - Generar billetes (completos y fracciones)
  - Comprar billetes/fracciones
  - Ejecutar sorteos y seleccionar ganadores
  - Devolver billetes
  - Gestionar estado de sorteos

  Integración:
  - Usa validaciones de AzarShared.Validations
  - Persiste en JSON con AzarShared.JsonHelper
  - Calcula valores con AzarShared.Calculations
  - Utiliza randomización con AzarShared.RandomHelper
  - Registra auditoría vía Audit.Operations
  """

  alias AzarServer.Contexts.Draws.Draw
  alias AzarServer.Contexts.Draws.Schemas.{Ticket, Prize, Fraction}
  alias AzarServer.Contexts.Audit
  alias AzarShared.{Validations, Calculations, JsonHelper, RandomHelper, Constants}

  @draws_file "priv/data/draws.json"
  @tickets_file "priv/data/tickets.json"
  @fractions_file "priv/data/fractions.json"
  @prizes_file "priv/data/prizes.json"

  # ============================================================================
  # SORTEOS
  # ============================================================================

  @doc """
  Crea un nuevo sorteo.

  Parámetros requeridos:
  - name: nombre del sorteo
  - draw_date: fecha de ejecución (DateTime)
  - full_ticket_value: precio del billete completo (número)
  - fractions_count: cantidad de fracciones por billete (>= 2)
  - total_tickets: cantidad de billetes disponibles

  Retorna:
  - {:ok, draw} si la creación fue exitosa
  - {:error, reason} si hay validación fallida

  Registra auditoría de creación.
  """
  @spec create_draw(map()) :: {:ok, Draw.t()} | {:error, String.t()}
  def create_draw(attrs) do
    with :ok <- validate_draw_params(attrs),
         draw = Draw.new(attrs),
         :ok <- JsonHelper.append_to_json_array(@draws_file, draw),
         :ok <- Audit.Operations.log_action("create", "draw", draw.id, attrs[:user_id], attrs[:user_name], "Sorteo creado: #{draw.name}") do
      {:ok, draw}
    else
      error -> error
    end
  end

  @doc """
  Obtiene un sorteo por ID.

  Retorna:
  - {:ok, draw} si el sorteo existe
  - {:error, "Sorteo no encontrado"} si no existe
  """
  @spec get_draw(String.t()) :: {:ok, Draw.t()} | {:error, String.t()}
  def get_draw(draw_id) do
    case JsonHelper.get_from_json(@draws_file, draw_id) do
      {:ok, draw_data} -> {:ok, Draw.new(draw_data)}
      error -> error
    end
  end

  @doc """
  Lista todos los sorteos.

  Retorna lista de struct Draw.
  """
  @spec list_draws() :: {:ok, [Draw.t()]} | {:error, String.t()}
  def list_draws do
    case JsonHelper.read_json(@draws_file) do
      {:ok, draws} ->
        draws_structs = Enum.map(draws, &Draw.new/1)
        {:ok, draws_structs}

      error ->
        error
    end
  end

  @doc """
  Ejecuta un sorteo (genera ganadores).

  Requiere:
  - draw_id: ID del sorteo
  - winning_numbers: lista de números ganadores

  Pasos:
  1. Valida que el sorteo esté "open"
  2. Selecciona ganadores
  3. Marca billetes/fracciones como ganadores/perdedores
  4. Actualiza estado a "executed"
  5. Registra auditoría

  Retorna:
  - {:ok, draw} con estado actualizado
  - {:error, reason} si hay problema
  """
  @spec execute_draw(String.t(), [String.t()], String.t(), String.t()) :: {:ok, Draw.t()} | {:error, String.t()}
  def execute_draw(draw_id, winning_numbers, user_id, user_name) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- validate_draw_status(draw, "open"),
         updated_draw = %{draw | status: "executed", winning_numbers: winning_numbers, executed_at: DateTime.utc_now()},
         :ok <- JsonHelper.update_json_key(@draws_file, draw_id, updated_draw),
         :ok <- mark_tickets_by_winners(draw_id, winning_numbers),
         :ok <- Audit.Operations.log_action("execute", "draw", draw_id, user_id, user_name, "Sorteo ejecutado con números ganadores: #{Enum.join(winning_numbers, ", ")}") do
      {:ok, updated_draw}
    else
      error -> error
    end
  end

  @doc """
  Cancela un sorteo y devuelve todos los billetes.

  Solo permite si el sorteo está "open".
  Marca todos los billetes como "returned".
  """
  @spec cancel_draw(String.t(), String.t(), String.t()) :: {:ok, Draw.t()} | {:error, String.t()}
  def cancel_draw(draw_id, user_id, user_name) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- validate_draw_status(draw, "open"),
         updated_draw = %{draw | status: "cancelled"},
         :ok <- JsonHelper.update_json_key(@draws_file, draw_id, updated_draw),
         :ok <- return_all_tickets(draw_id),
         :ok <- Audit.Operations.log_action("delete", "draw", draw_id, user_id, user_name, "Sorteo cancelado") do
      {:ok, updated_draw}
    else
      error -> error
    end
  end

  # ============================================================================
  # BILLETES (COMPLETOS Y FRACCIONES)
  # ============================================================================

  @doc """
  Genera todos los billetes para un sorteo.

  Crea:
  - total_tickets billetes de tipo "complete"
  - total_tickets * fractions_count billetes de tipo "fraction"

  Los billetes se crean con status "active" y disponibles para compra.
  """
  @spec generate_tickets(String.t(), integer()) :: {:ok, {integer(), integer()}} | {:error, String.t()}
  def generate_tickets(draw_id, count \\ nil) do
    with {:ok, draw} <- get_draw(draw_id),
         total_count = count || draw.total_tickets,
         :ok <- validate_ticket_count(total_count),
         complete_tickets = generate_complete_tickets(draw_id, draw, total_count),
         fractions = generate_fractions(draw_id, draw, total_count),
         :ok <- Enum.each(complete_tickets, &JsonHelper.append_to_json_array(@tickets_file, &1)),
         :ok <- Enum.each(fractions, &JsonHelper.append_to_json_array(@fractions_file, &1)) do
      {:ok, {length(complete_tickets), length(fractions)}}
    else
      error -> error
    end
  end

  @doc """
  Compra un billete completo.

  Parámetros:
  - draw_id: ID del sorteo
  - user_id: usuario que compra
  - user_name: nombre del usuario

  Pasos:
  1. Obtiene billete disponible
  2. Marca como comprado (owner)
  3. Actualiza available_tickets del sorteo
  4. Registra auditoría

  Retorna:
  - {:ok, ticket} ticket comprado
  - {:error, reason} si no hay disponibles o validación falla
  """
  @spec purchase_complete_ticket(String.t(), String.t(), String.t()) :: {:ok, Ticket.t()} | {:error, String.t()}
  def purchase_complete_ticket(draw_id, user_id, user_name) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- validate_draw_status(draw, "open"),
         {:ok, ticket} <- get_available_ticket(draw_id, "complete"),
         purchase_price = draw.full_ticket_value,
         updated_ticket = %{ticket | owner: user_id, owner_name: user_name, status: "active", purchase_price: purchase_price},
         :ok <- JsonHelper.update_json_key(@tickets_file, ticket.id, updated_ticket),
         new_available = draw.available_tickets - 1,
         updated_draw = %{draw | available_tickets: new_available},
         :ok <- JsonHelper.update_json_key(@draws_file, draw_id, updated_draw),
         :ok <- Audit.Operations.log_action("buy", "ticket", ticket.id, user_id, user_name, "Billete completo comprado") do
      {:ok, updated_ticket}
    else
      error -> error
    end
  end

  @doc """
  Compra una fracción de billete.

  Parámetros:
  - draw_id: ID del sorteo
  - user_id: usuario que compra
  - user_name: nombre del usuario

  Selecciona una fracción disponible, la asigna y actualiza el sorteo.
  """
  @spec purchase_fraction(String.t(), String.t(), String.t()) :: {:ok, Fraction.t()} | {:error, String.t()}
  def purchase_fraction(draw_id, user_id, user_name) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- validate_draw_status(draw, "open"),
         {:ok, fraction} <- get_available_fraction(draw_id),
         fraction_price = Calculations.calculate_fraction_value(draw.full_ticket_value, draw.fractions_count),
         updated_fraction = %{fraction | owner: user_id, owner_name: user_name, status: "active", purchase_price: fraction_price},
         :ok <- JsonHelper.update_json_key(@fractions_file, fraction.id, updated_fraction),
         new_available = draw.available_tickets - 1,
         updated_draw = %{draw | available_tickets: new_available},
         :ok <- JsonHelper.update_json_key(@draws_file, draw_id, updated_draw),
         :ok <- Audit.Operations.log_action("buy", "fraction", fraction.id, user_id, user_name, "Fracción #{fraction.fraction_number}/#{fraction.total_fractions} comprada") do
      {:ok, updated_fraction}
    else
      error -> error
    end
  end

  @doc """
  Devuelve un billete completo.

  Marca como "returned" y devuelve el dinero al usuario.
  Solo permite billetes en estado "active".
  """
  @spec return_ticket(String.t(), String.t(), String.t()) :: {:ok, Ticket.t()} | {:error, String.t()}
  def return_ticket(ticket_id, user_id, user_name) do
    with {:ok, ticket} <- get_ticket(ticket_id),
         :ok <- validate_ticket_status(ticket, "active"),
         {:ok, draw} <- get_draw(ticket.draw_id),
         updated_ticket = %{ticket | status: "returned"},
         :ok <- JsonHelper.update_json_key(@tickets_file, ticket_id, updated_ticket),
         new_available = draw.available_tickets + 1,
         updated_draw = %{draw | available_tickets: new_available},
         :ok <- JsonHelper.update_json_key(@draws_file, draw.id, updated_draw),
         :ok <- Audit.Operations.log_action("return", "ticket", ticket_id, user_id, user_name, "Billete devuelto") do
      {:ok, updated_ticket}
    else
      error -> error
    end
  end

  @doc """
  Devuelve una fracción.

  Similar a return_ticket pero para fracciones.
  """
  @spec return_fraction(String.t(), String.t(), String.t()) :: {:ok, Fraction.t()} | {:error, String.t()}
  def return_fraction(fraction_id, user_id, user_name) do
    with {:ok, fraction} <- get_fraction(fraction_id),
         :ok <- validate_fraction_status(fraction, "active"),
         {:ok, draw} <- get_draw(fraction.draw_id),
         updated_fraction = %{fraction | status: "returned"},
         :ok <- JsonHelper.update_json_key(@fractions_file, fraction_id, updated_fraction),
         new_available = draw.available_tickets + 1,
         updated_draw = %{draw | available_tickets: new_available},
         :ok <- JsonHelper.update_json_key(@draws_file, draw.id, updated_draw),
         :ok <- Audit.Operations.log_action("return", "fraction", fraction_id, user_id, user_name, "Fracción devuelta") do
      {:ok, updated_fraction}
    else
      error -> error
    end
  end

  @doc """
  Obtiene un billete por ID.
  """
  @spec get_ticket(String.t()) :: {:ok, Ticket.t()} | {:error, String.t()}
  def get_ticket(ticket_id) do
    case JsonHelper.get_from_json(@tickets_file, ticket_id) do
      {:ok, ticket_data} -> {:ok, Ticket.new(ticket_data)}
      error -> error
    end
  end

  @doc """
  Obtiene una fracción por ID.
  """
  @spec get_fraction(String.t()) :: {:ok, Fraction.t()} | {:error, String.t()}
  def get_fraction(fraction_id) do
    case JsonHelper.get_from_json(@fractions_file, fraction_id) do
      {:ok, fraction_data} -> {:ok, Fraction.new(fraction_data)}
      error -> error
    end
  end

  @doc """
  Lista todos los billetes de un sorteo.

  Opcionalmente filtrar por tipo: "complete" o "fraction".
  """
  @spec list_tickets(String.t(), String.t() | nil) :: {:ok, [Ticket.t()]} | {:error, String.t()}
  def list_tickets(draw_id, type \\ nil) do
    case JsonHelper.read_json(@tickets_file) do
      {:ok, tickets} ->
        filtered =
          tickets
          |> Enum.filter(&(&1["draw_id"] == draw_id))
          |> Enum.filter(&match_ticket_type(&1, type))
          |> Enum.map(&Ticket.new/1)

        {:ok, filtered}

      error ->
        error
    end
  end

  @doc """
  Lista todas las fracciones de un sorteo.
  """
  @spec list_fractions(String.t()) :: {:ok, [Fraction.t()]} | {:error, String.t()}
  def list_fractions(draw_id) do
    case JsonHelper.read_json(@fractions_file) do
      {:ok, fractions} ->
        filtered =
          fractions
          |> Enum.filter(&(&1["draw_id"] == draw_id))
          |> Enum.map(&Fraction.new/1)

        {:ok, filtered}

      error ->
        error
    end
  end

  # ============================================================================
  # PREMIOS
  # ============================================================================

  @doc """
  Crea un premio para un sorteo.

  Parámetros:
  - draw_id: ID del sorteo
  - name: nombre del premio
  - value: monto a premiar
  - associated_numbers: lista de números que ganan

  Valida que el nombre no sea duplicado en el sorteo.
  """
  @spec create_prize(map()) :: {:ok, Prize.t()} | {:error, String.t()}
  def create_prize(attrs) do
    with :ok <- validate_prize_params(attrs),
         :ok <- validate_unique_prize_name(attrs[:draw_id], attrs[:name]),
         prize = Prize.new(attrs),
         :ok <- JsonHelper.append_to_json_array(@prizes_file, prize),
         :ok <- Audit.Operations.log_action("create", "prize", prize.id, attrs[:user_id], attrs[:user_name], "Premio creado: #{prize.name}") do
      {:ok, prize}
    else
      error -> error
    end
  end

  @doc """
  Obtiene un premio por ID.
  """
  @spec get_prize(String.t()) :: {:ok, Prize.t()} | {:error, String.t()}
  def get_prize(prize_id) do
    case JsonHelper.get_from_json(@prizes_file, prize_id) do
      {:ok, prize_data} -> {:ok, Prize.new(prize_data)}
      error -> error
    end
  end

  @doc """
  Lista todos los premios de un sorteo.
  """
  @spec list_prizes(String.t()) :: {:ok, [Prize.t()]} | {:error, String.t()}
  def list_prizes(draw_id) do
    case JsonHelper.read_json(@prizes_file) do
      {:ok, prizes} ->
        filtered =
          prizes
          |> Enum.filter(&(&1["draw_id"] == draw_id))
          |> Enum.map(&Prize.new/1)

        {:ok, filtered}

      error ->
        error
    end
  end

  @doc """
  Elimina un premio.

  Solo permite si no tiene ganadores asignados.
  """
  @spec delete_prize(String.t(), String.t(), String.t()) :: {:ok, Prize.t()} | {:error, String.t()}
  def delete_prize(prize_id, user_id, user_name) do
    with {:ok, prize} <- get_prize(prize_id),
         :ok <- validate_no_winners(prize),
         :ok <- JsonHelper.update_json_key(@prizes_file, prize_id, nil),
         :ok <- Audit.Operations.log_action("delete", "prize", prize_id, user_id, user_name, "Premio eliminado: #{prize.name}") do
      {:ok, prize}
    else
      error -> error
    end
  end

  # ============================================================================
  # VALIDACIONES PRIVADAS
  # ============================================================================

  defp validate_draw_params(attrs) do
    with :ok <- Validations.validate_required([:name, :draw_date, :full_ticket_value, :fractions_count, :total_tickets], attrs),
         :ok <- Validations.validate_amount(attrs[:full_ticket_value]),
         :ok <- Validations.validate_date(attrs[:draw_date]),
         true <- attrs[:fractions_count] >= 2 || {:error, "Fracciones mínimas: 2"},
         true <- attrs[:total_tickets] > 0 || {:error, "Billetes mínimos: 1"} do
      :ok
    else
      error -> error
    end
  end

  defp validate_prize_params(attrs) do
    with :ok <- Validations.validate_required([:draw_id, :name, :value], attrs),
         :ok <- Validations.validate_amount(attrs[:value]),
         true <- String.length(attrs[:name]) > 0 || {:error, "Nombre de premio requerido"} do
      :ok
    else
      error -> error
    end
  end

  defp validate_draw_status(draw, expected_status) do
    if draw.status == expected_status do
      :ok
    else
      {:error, "Estado de sorteo inválido. Esperado: #{expected_status}, Actual: #{draw.status}"}
    end
  end

  defp validate_ticket_status(ticket, expected_status) do
    if ticket.status == expected_status do
      :ok
    else
      {:error, "Estado de billete inválido. Esperado: #{expected_status}, Actual: #{ticket.status}"}
    end
  end

  defp validate_fraction_status(fraction, expected_status) do
    if fraction.status == expected_status do
      :ok
    else
      {:error, "Estado de fracción inválido. Esperado: #{expected_status}, Actual: #{fraction.status}"}
    end
  end

  defp validate_ticket_count(count) do
    if count > 0 and count <= 999 do
      :ok
    else
      {:error, "Cantidad de billetes debe estar entre 1 y 999"}
    end
  end

  defp validate_unique_prize_name(draw_id, name) do
    case list_prizes(draw_id) do
      {:ok, prizes} ->
        if Enum.any?(prizes, &(&1.name == name)) do
          {:error, "Ya existe un premio con ese nombre en este sorteo"}
        else
          :ok
        end

      error ->
        error
    end
  end

  defp validate_no_winners(prize) do
    if prize.awarded_to == nil or prize.awarded_to == "" do
      :ok
    else
      {:error, "No se puede eliminar premio que ya tiene ganador"}
    end
  end

  # ============================================================================
  # HELPERS PRIVADOS
  # ============================================================================

  defp generate_complete_tickets(draw_id, draw, count) do
    1..count
    |> Enum.map(fn n ->
      Ticket.new(%{
        number: String.pad_leading(Integer.to_string(n), 3, "0"),
        draw_id: draw_id,
        ticket_type: "complete",
        owner: nil,
        owner_name: nil,
        purchase_price: 0
      })
    end)
  end

  defp generate_fractions(draw_id, draw, count) do
    1..count
    |> Enum.flat_map(fn ticket_num ->
      ticket_number = String.pad_leading(Integer.to_string(ticket_num), 3, "0")

      1..draw.fractions_count
      |> Enum.map(fn frac_num ->
        fraction_price = Calculations.calculate_fraction_value(draw.full_ticket_value, draw.fractions_count)

        Fraction.new(%{
          ticket_number: ticket_number,
          draw_id: draw_id,
          ticket_id: "ticket_#{draw_id}_#{ticket_number}",
          fraction_number: frac_num,
          total_fractions: draw.fractions_count,
          owner: nil,
          owner_name: nil,
          fraction_price: fraction_price,
          purchase_price: fraction_price
        })
      end)
    end)
  end

  defp get_available_ticket(draw_id, type) do
    case list_tickets(draw_id, type) do
      {:ok, tickets} ->
        available = Enum.find(tickets, &(&1.owner == nil))

        if available do
          {:ok, available}
        else
          {:error, "No hay billetes #{type} disponibles"}
        end

      error ->
        error
    end
  end

  defp get_available_fraction(draw_id) do
    case list_fractions(draw_id) do
      {:ok, fractions} ->
        available = Enum.find(fractions, &(&1.owner == nil))

        if available do
          {:ok, available}
        else
          {:error, "No hay fracciones disponibles"}
        end

      error ->
        error
    end
  end

  defp mark_tickets_by_winners(draw_id, winning_numbers) do
    case list_tickets(draw_id) do
      {:ok, tickets} ->
        Enum.each(tickets, fn ticket ->
          if Enum.member?(winning_numbers, ticket.number) do
            updated = %{ticket | status: "winner"}
            JsonHelper.update_json_key(@tickets_file, ticket.id, updated)
          else
            updated = %{ticket | status: "loser"}
            JsonHelper.update_json_key(@tickets_file, ticket.id, updated)
          end
        end)

        :ok

      error ->
        error
    end
  end

  defp return_all_tickets(draw_id) do
    case list_tickets(draw_id) do
      {:ok, tickets} ->
        Enum.each(tickets, fn ticket ->
          updated = %{ticket | status: "returned"}
          JsonHelper.update_json_key(@tickets_file, ticket.id, updated)
        end)

        :ok

      error ->
        error
    end
  end

  defp match_ticket_type(_ticket, nil), do: true
  defp match_ticket_type(ticket, type), do: ticket["ticket_type"] == type
end
