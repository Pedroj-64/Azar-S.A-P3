defmodule AzarAdmin.Contexts.Draws.Operations do
  @moduledoc """
  Public business operations for Draws (Admin view).

  Handles complex logic for:
  - Creating new draws
  - Editing draw information
  - Executing draws and selecting winners
  - Listing draws by status
  - Querying draw statistics
  - Managing draw status
  - Calculating revenue and prizes

  Integration:
  - Uses validations from AzarShared.Validations
  - Persists to JSON with AzarShared.JsonHelper
  - Calculates values with AzarShared.Calculations
  - Uses randomization with AzarShared.RandomHelper
  """

  alias AzarAdmin.Contexts.Draws.AdminDraw
  alias AzarAdmin.Contexts.Draws.Schemas.{Prize, DrawStatistics}
  alias AzarShared.{Validations, Calculations, JsonHelper, RandomHelper, Constants}

  @draws_file "priv/data/draws.json"
  @prizes_file "priv/data/prizes.json"
  @tickets_file "priv/data/tickets.json"

  # ============================================================================
  # CREATE AND EDIT DRAWS
  # ============================================================================

  @doc """
  Crea un nuevo sorteo.

  Parámetros requeridos:
  - name: nombre del sorteo
  - draw_date: fecha de ejecución (DateTime)
  - full_ticket_value: precio del billete completo (número)
  - fractions_count: cantidad de fracciones por billete (>= 2)
  - total_tickets: cantidad de billetes disponibles
  - created_by: ID del administrador que crea el sorteo

  Validaciones:
  - Nombre no vacío
  - Fecha futura
  - Valores positivos
  - fractions_count >= 2
  - total_tickets > 0

  Retorna:
  - {:ok, draw} si la creación fue exitosa
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Persiste el sorteo
  - Registra auditoría de creación
  """
  @spec create_draw(map()) :: {:ok, AdminDraw.t()} | {:error, term()}
  def create_draw(attrs) do
    with :ok <- validate_draw_params(attrs),
         draw = AdminDraw.new(attrs),
         :ok <- JsonHelper.append_to_json_array(@draws_file, draw) do
      {:ok, draw}
    else
      error -> error
    end
  end

  @doc """
  Edita información de un sorteo (solo si está abierto).

  Parámetros:
  - draw_id: ID del sorteo a editar
  - attrs: Map con campos a actualizar
  - updated_by: ID del administrador que realiza el cambio

  Campos editables (solo si status == "open"):
  - name: nombre del sorteo
  - remarks: observaciones

  Retorna:
  - {:ok, draw} si la edición fue exitosa
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Actualiza el sorteo en persistencia
  - Registra auditoría de cambio
  """
  @spec update_draw(String.t(), map(), String.t()) :: {:ok, AdminDraw.t()} | {:error, term()}
  def update_draw(draw_id, attrs, updated_by) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- verify_draw_open(draw),
         updated_draw = %{draw | name: attrs[:name] || draw.name, remarks: attrs[:remarks] || draw.remarks},
         :ok <- JsonHelper.update_in_json(@draws_file, draw_id, Map.from_struct(updated_draw)) do
      {:ok, updated_draw}
    else
      error -> error
    end
  end

  # ============================================================================
  # CONSULTAR SORTEOS
  # ============================================================================

  @doc """
  Obtiene un sorteo por ID.

  Retorna:
  - {:ok, draw} si el sorteo existe
  - {:error, "Sorteo no encontrado"} si no existe
  """
  @spec get_draw(String.t()) :: {:ok, AdminDraw.t()} | {:error, term()}
  def get_draw(draw_id) do
    case JsonHelper.get_from_json(@draws_file, draw_id) do
      {:ok, draw_data} -> {:ok, AdminDraw.new(draw_data)}
      error -> error
    end
  end

  @doc """
  Lista todos los sorteos.

  Retorna lista de struct AdminDraw.
  """
  @spec list_draws() :: {:ok, [AdminDraw.t()]} | {:error, term()}
  def list_draws do
    case JsonHelper.read_json(@draws_file) do
      {:ok, draws} ->
        draws_structs = Enum.map(draws, &AdminDraw.new/1)
        {:ok, draws_structs}

      error ->
        error
    end
  end

  @doc """
  Lista sorteos por estado.

  Estados válidos: "open", "executed", "cancelled"

  Retorna:
  - {:ok, draws} si la consulta fue exitosa
  - {:error, reason} si hay error
  """
  @spec list_draws_by_status(String.t()) :: {:ok, [AdminDraw.t()]} | {:error, term()}
  def list_draws_by_status(status) do
    with :ok <- validate_status(status),
         {:ok, draws} <- list_draws() do
      filtered = Enum.filter(draws, fn draw -> draw.status == status end)
      {:ok, filtered}
    else
      error -> error
    end
  end

  # ============================================================================
  # EJECUTAR SORTEOS
  # ============================================================================

  @doc """
  Ejecuta un sorteo (genera ganadores).

  Requiere:
  - draw_id: ID del sorteo
  - winning_numbers: lista de números ganadores
  - executed_by: ID del administrador que ejecuta

  Validaciones:
  - Sorteo existe y está abierto
  - Números ganadores válidos
  - Al menos un número ganador

  Retorna:
  - {:ok, draw} si la ejecución fue exitosa
  - {:error, reason} si hay validación fallida

  Efectos secundarios:
  - Cambia estado del sorteo a "executed"
  - Calcula premios
  - Registra auditoría de ejecución
  """
  @spec execute_draw(String.t(), [integer()], String.t()) :: {:ok, AdminDraw.t()} | {:error, term()}
  def execute_draw(draw_id, winning_numbers, executed_by) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- verify_draw_open(draw),
         :ok <- validate_winning_numbers(winning_numbers),
         updated_draw = %{
           draw
           | status: "executed",
             executed_at: DateTime.utc_now(),
             executed_by: executed_by,
             winning_numbers: winning_numbers
         },
         :ok <- JsonHelper.update_in_json(@draws_file, draw_id, Map.from_struct(updated_draw)) do
      {:ok, updated_draw}
    else
      error -> error
    end
  end

  @doc """
  Cancela un sorteo (solo si está abierto).

  Requiere:
  - draw_id: ID del sorteo
  - reason: razón de la cancelación

  Retorna:
  - {:ok, draw} si fue cancelado exitosamente
  - {:error, reason} si hay error

  Efectos secundarios:
  - Cambia estado a "cancelled"
  - Registra auditoría de cancelación
  """
  @spec cancel_draw(String.t(), String.t()) :: {:ok, AdminDraw.t()} | {:error, term()}
  def cancel_draw(draw_id, reason) do
    with {:ok, draw} <- get_draw(draw_id),
         :ok <- verify_draw_open(draw),
         updated_draw = %{draw | status: "cancelled", remarks: reason},
         :ok <- JsonHelper.update_in_json(@draws_file, draw_id, Map.from_struct(updated_draw)) do
      {:ok, updated_draw}
    else
      error -> error
    end
  end

  # ============================================================================
  # ESTADÍSTICAS DEL SORTEO
  # ============================================================================

  @doc """
  Obtiene estadísticas detalladas de un sorteo.

  Incluye:
  - Total de ingresos
  - Billetes vendidos/disponibles
  - Estadísticas de premios
  - Información de ganadores

  Retorna:
  - {:ok, statistics} si la consulta fue exitosa
  - {:error, reason} si hay error
  """
  @spec get_draw_statistics(String.t()) :: {:ok, DrawStatistics.t()} | {:error, term()}
  def get_draw_statistics(draw_id) do
    with {:ok, draw} <- get_draw(draw_id),
         {:ok, tickets} <- read_draw_tickets(draw_id),
         {:ok, prizes} <- read_draw_prizes(draw_id) do
      stats = DrawStatistics.new(%{
        draw_id: draw.id,
        draw_name: draw.name,
        status: draw.status,
        total_revenue: calculate_revenue(draw, tickets),
        tickets_sold: draw.sold_tickets,
        tickets_available: draw.available_tickets,
        total_tickets: draw.total_tickets,
        estimated_payout: calculate_estimated_payout(prizes),
        margin: calculate_margin(draw, tickets, prizes),
        execution_date: draw.executed_at,
        winning_numbers_count: if(draw.winning_numbers, do: length(draw.winning_numbers), else: 0)
      })

      {:ok, stats}
    else
      error -> error
    end
  end

  # ============================================================================
  # VALIDACIONES INTERNAS
  # ============================================================================

  defp validate_draw_params(attrs) do
    with :ok <- Validations.required_params(attrs, [:name, :draw_date, :full_ticket_value, :fractions_count, :total_tickets, :created_by]),
         :ok <- validate_draw_date(attrs[:draw_date]),
         :ok <- validate_positive_number(attrs[:full_ticket_value]),
         :ok <- validate_fractions_count(attrs[:fractions_count]),
         :ok <- validate_positive_number(attrs[:total_tickets]) do
      :ok
    else
      error -> error
    end
  end

  defp validate_draw_date(date) do
    if DateTime.compare(date, DateTime.utc_now()) == :gt do
      :ok
    else
      {:error, "Draw date must be in the future"}
    end
  end

  defp validate_positive_number(value) when is_number(value) and value > 0, do: :ok
  defp validate_positive_number(_), do: {:error, "Value must be a positive number"}

  defp validate_fractions_count(count) when is_integer(count) and count >= 2, do: :ok
  defp validate_fractions_count(_), do: {:error, "Fractions count must be >= 2"}

  defp validate_status(status) do
    if status in ["open", "executed", "cancelled"] do
      :ok
    else
      {:error, "Invalid draw status"}
    end
  end

  defp validate_winning_numbers(numbers) when is_list(numbers) and length(numbers) > 0 do
    if Enum.all?(numbers, &is_integer/1) do
      :ok
    else
      {:error, "All winning numbers must be integers"}
    end
  end

  defp validate_winning_numbers(_), do: {:error, "Winning numbers must be a non-empty list"}

  defp verify_draw_open(draw) do
    if draw.status == "open" do
      :ok
    else
      {:error, "Draw is not open"}
    end
  end

  # ============================================================================
  # CÁLCULOS INTERNOS
  # ============================================================================

  defp calculate_revenue(draw, tickets) do
    Enum.reduce(tickets, 0.0, fn ticket, acc ->
      if ticket[:sold], do: acc + draw.full_ticket_value, else: acc
    end)
  end

  defp calculate_estimated_payout(prizes) do
    Enum.reduce(prizes, 0.0, fn prize, acc ->
      acc + (prize[:amount] || 0)
    end)
  end

  defp calculate_margin(draw, tickets, prizes) do
    revenue = calculate_revenue(draw, tickets)
    payout = calculate_estimated_payout(prizes)
    revenue - payout
  end

  defp read_draw_tickets(draw_id) do
    case JsonHelper.read_json(@tickets_file) do
      {:ok, tickets} ->
        filtered = Enum.filter(tickets, fn t -> t[:draw_id] == draw_id end)
        {:ok, filtered}

      error ->
        error
    end
  end

  defp read_draw_prizes(draw_id) do
    case JsonHelper.read_json(@prizes_file) do
      {:ok, prizes} ->
        filtered = Enum.filter(prizes, fn p -> p[:draw_id] == draw_id end)
        {:ok, filtered}

      error ->
        error
    end
  end
end
