defmodule AzarAdmin.Controllers.DrawController do
  @moduledoc """
  Controller para gestión de sorteos.

  Proporciona endpoints para:
  - Crear nuevos sorteos
  - Editar sorteos
  - Listar sorteos por estado
  - Obtener detalles de un sorteo
  - Ejecutar sorteos
  - Cancelar sorteos
  - Ver estadísticas del sorteo
  """

  use Phoenix.Controller

  alias AzarAdmin.Contexts.Draws.Operations, as: DrawOps
  alias AzarShared.Errors

  @doc """
  Crea un nuevo sorteo.

  Parámetros esperados:
  - name: String - nombre del sorteo
  - draw_date: DateTime - fecha de ejecución
  - full_ticket_value: number - precio del billete completo
  - fractions_count: integer - cantidad de fracciones (>= 2)
  - total_tickets: integer - cantidad total de billetes
  - created_by: String - ID del admin que crea

  Retorna:
  - 201 Created: Sorteo creado exitosamente
  - 400 Bad Request: Validación fallida
  - 500 Error: Error en servidor
  """
  def create(conn, %{"draw" => draw_params}) do
    case DrawOps.create_draw(draw_params) do
      {:ok, draw} ->
        conn
        |> put_status(:created)
        |> json(%{
          status: "ok",
          message: "Draw created successfully",
          draw: format_draw_response(draw)
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Edita un sorteo (solo si está abierto).

  Parámetros:
  - draw_id: String - ID del sorteo
  - name: String - nuevo nombre (opcional)
  - remarks: String - nuevas observaciones (opcional)
  - updated_by: String - ID del admin que realiza el cambio

  Retorna:
  - 200 OK: Sorteo actualizado
  - 400 Bad Request: Validación fallida
  - 404 Not Found: Sorteo no existe
  """
  def update(conn, %{"draw_id" => draw_id} = params) do
    case DrawOps.update_draw(draw_id, params, params["updated_by"]) do
      {:ok, draw} ->
        json(conn, %{
          status: "ok",
          message: "Draw updated successfully",
          draw: format_draw_response(draw)
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene detalles de un sorteo específico.

  Retorna:
  - 200 OK: Detalles del sorteo
  - 404 Not Found: Sorteo no existe
  """
  def get(conn, %{"draw_id" => draw_id}) do
    case DrawOps.get_draw(draw_id) do
      {:ok, draw} ->
        json(conn, %{
          status: "ok",
          draw: format_draw_response(draw)
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista todos los sorteos.

  Retorna:
  - 200 OK: Lista de sorteos
  - 500 Error: Error en servidor
  """
  def list(conn, _params) do
    case DrawOps.list_draws() do
      {:ok, draws} ->
        json(conn, %{
          status: "ok",
          draws: Enum.map(draws, &format_draw_response/1),
          total: length(draws)
        })

      {:error, reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Lista sorteos por estado.

  Parámetros:
  - status: String - estado del sorteo ("open", "executed", "cancelled")

  Retorna:
  - 200 OK: Lista de sorteos filtrada
  - 400 Bad Request: Estado inválido
  """
  def list_by_status(conn, %{"status" => status}) do
    case DrawOps.list_draws_by_status(status) do
      {:ok, draws} ->
        json(conn, %{
          status: "ok",
          draws: Enum.map(draws, &format_draw_response/1),
          total: length(draws),
          filter: status
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Ejecuta un sorteo (genera ganadores).

  Parámetros:
  - draw_id: String - ID del sorteo
  - winning_numbers: [integer] - lista de números ganadores
  - executed_by: String - ID del admin que ejecuta

  Retorna:
  - 200 OK: Sorteo ejecutado exitosamente
  - 400 Bad Request: Validación fallida
  - 404 Not Found: Sorteo no existe
  """
  def execute(conn, %{
    "draw_id" => draw_id,
    "winning_numbers" => winning_numbers,
    "executed_by" => executed_by
  }) do
    case DrawOps.execute_draw(draw_id, winning_numbers, executed_by) do
      {:ok, draw} ->
        json(conn, %{
          status: "ok",
          message: "Draw executed successfully",
          draw: format_draw_response(draw)
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Cancela un sorteo (solo si está abierto).

  Parámetros:
  - draw_id: String - ID del sorteo
  - reason: String - razón de la cancelación

  Retorna:
  - 200 OK: Sorteo cancelado
  - 400 Bad Request: No puede cancelarse
  - 404 Not Found: Sorteo no existe
  """
  def cancel(conn, %{"draw_id" => draw_id, "reason" => reason}) do
    case DrawOps.cancel_draw(draw_id, reason) do
      {:ok, draw} ->
        json(conn, %{
          status: "ok",
          message: "Draw cancelled successfully",
          draw: format_draw_response(draw)
        })

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  @doc """
  Obtiene estadísticas detalladas de un sorteo.

  Incluye ingresos, billetes vendidos, premios, margen, etc.

  Retorna:
  - 200 OK: Estadísticas del sorteo
  - 404 Not Found: Sorteo no existe
  """
  def statistics(conn, %{"draw_id" => draw_id}) do
    case DrawOps.get_draw_statistics(draw_id) do
      {:ok, stats} ->
        json(conn, %{
          status: "ok",
          statistics: %{
            draw_id: stats.draw_id,
            draw_name: stats.draw_name,
            status: stats.status,
            total_revenue: stats.total_revenue,
            tickets_sold: stats.tickets_sold,
            tickets_available: stats.tickets_available,
            total_tickets: stats.total_tickets,
            estimated_payout: stats.estimated_payout,
            margin: stats.margin,
            margin_percentage: calculate_margin_percentage(stats.margin, stats.total_revenue),
            execution_date: stats.execution_date,
            winning_numbers_count: stats.winning_numbers_count
          }
        })

      {:error, reason} ->
        conn
        |> put_status(:not_found)
        |> json(%{
          status: "error",
          message: reason
        })
    end
  end

  # ============================================================================
  # FUNCIONES AUXILIARES
  # ============================================================================

  defp format_draw_response(draw) do
    %{
      id: draw.id,
      name: draw.name,
      draw_date: draw.draw_date,
      full_ticket_value: draw.full_ticket_value,
      fractions_count: draw.fractions_count,
      total_tickets: draw.total_tickets,
      available_tickets: draw.available_tickets,
      sold_tickets: draw.sold_tickets,
      status: draw.status,
      total_revenue: draw.total_revenue,
      created_at: draw.created_at,
      created_by: draw.created_by,
      executed_at: draw.executed_at,
      executed_by: draw.executed_by,
      winning_numbers: draw.winning_numbers,
      remarks: draw.remarks
    }
  end

  defp calculate_margin_percentage(margin, revenue) when revenue > 0 do
    Float.round((margin / revenue) * 100, 2)
  end

  defp calculate_margin_percentage(_, _), do: 0.0
end
