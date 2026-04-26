defmodule AzarServer.Controllers.DrawController do
  @moduledoc """
  Controller para gestión de sorteos.

  Proporciona endpoints para:
  - Crear nuevos sorteos
  - Listar sorteos disponibles
  - Obtener detalles de un sorteo
  - Ejecutar sorteos (seleccionar ganadores)
  - Actualizar información de sorteos
  - Eliminar sorteos
  """

  use Phoenix.Controller

  alias AzarServer.Contexts.Draws.Operations, as: DrawOps

  @doc """
  Crea un nuevo sorteo.

  Parámetros esperados:
  - name: String (nombre del sorteo)
  - draw_date: DateTime (fecha de ejecución)
  - full_ticket_value: Decimal (precio billete completo)
  - fractions_count: Integer (cantidad de fracciones)
  - total_tickets: Integer (cantidad de billetes disponibles)

  Retorna:
  - 201 Created: Sorteo creado exitosamente
  - 400 Bad Request: Validación fallida
  """
  def create(conn, %{"draw" => draw_params}) do
    user_id = conn.assigns[:current_user_id]
    params_with_user = Map.merge(draw_params, %{
      "user_id" => user_id,
      "user_name" => conn.assigns[:current_user_name]
    })

    case DrawOps.create_draw(params_with_user) do
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
  Lista todos los sorteos.

  Parámetros:
  - status: String (opcional: "pending", "executed", "cancelled")
  - page: Integer (default: 1)
  - limit: Integer (default: 20)

  Retorna:
  - 200 OK: Lista paginada de sorteos
  """
  def list(conn, params) do
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "20") |> min(100)
    _status = params["status"]

    case DrawOps.list_draws() do
      {:ok, draws} ->
        paginated = paginate_list(draws, page, limit)

        json(conn, %{
          status: "ok",
          draws: Enum.map(paginated, &format_draw_response/1),
          page: page,
          limit: limit,
          total: Enum.count(draws)
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
  Obtiene detalles de un sorteo específico.

  Parámetros:
  - id: String (ID del sorteo)

  Retorna:
  - 200 OK: Detalles completos del sorteo
  - 404 Not Found: Sorteo no existe
  """
  def show(conn, %{"id" => draw_id}) do
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
  Ejecuta un sorteo (selecciona ganadores).

  Parámetros:
  - draw_id: String (ID del sorteo)

  Retorna:
  - 200 OK: Sorteo ejecutado, lista de ganadores
  - 400 Bad Request: Sorteo no puede ser ejecutado (fecha no llegó, etc)
  - 404 Not Found: Sorteo no existe
  """
  def execute(conn, %{"draw_id" => draw_id}) do
    user_id = conn.assigns[:current_user_id]

    case DrawOps.execute_draw(draw_id, user_id) do
      {:ok, {draw, winners}} ->
        json(conn, %{
          status: "ok",
          message: "Draw executed successfully",
          draw: format_draw_response(draw),
          winners_count: Enum.count(winners),
          winners: Enum.map(winners, &format_winner_response/1)
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
  Actualiza información de un sorteo.

  Parámetros:
  - name: String (opcional)
  - draw_date: DateTime (opcional)
  - additional_info: String (opcional)

  Retorna:
  - 200 OK: Sorteo actualizado
  - 400 Bad Request: Validación fallida
  - 404 Not Found: Sorteo no existe
  """
  def update(conn, %{"id" => draw_id, "draw" => draw_params}) do
    user_id = conn.assigns[:current_user_id]

    case DrawOps.update_draw(draw_id, draw_params, user_id) do
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
  Elimina un sorteo.

  Parámetros:
  - draw_id: String (ID del sorteo)

  Retorna:
  - 200 OK: Sorteo eliminado
  - 400 Bad Request: Sorteo no puede ser eliminado (tiene transacciones)
  - 404 Not Found: Sorteo no existe
  """
  def delete(conn, %{"id" => draw_id}) do
    user_id = conn.assigns[:current_user_id]

    case DrawOps.delete_draw(draw_id, user_id) do
      :ok ->
        json(conn, %{
          status: "ok",
          message: "Draw deleted successfully"
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
  Obtiene estadísticas de un sorteo.

  Retorna:
  - Total de billetes vendidos
  - Ingresos generados
  - Número de ganadores
  - Premios distribuidos
  """
  def statistics(conn, %{"id" => draw_id}) do
    case DrawOps.get_draw_statistics(draw_id) do
      {:ok, stats} ->
        json(conn, %{
          status: "ok",
          statistics: stats
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

  # Helpers

  defp format_draw_response(draw) do
    %{
      id: draw.id,
      name: draw.name,
      draw_date: draw.draw_date,
      created_at: draw.created_at,
      full_ticket_value: draw.full_ticket_value |> Decimal.to_string(),
      fractions_count: draw.fractions_count,
      total_tickets: draw.total_tickets,
      status: draw.status,
      executed_at: draw.executed_at
    }
  end

  defp format_winner_response(winner) do
    %{
      ticket_number: winner.ticket_number,
      fraction_number: winner.fraction_number,
      user_id: winner.user_id,
      prize_amount: winner.prize_amount |> Decimal.to_string(),
      prize_category: winner.prize_category
    }
  end

  defp paginate_list(list, page, limit) when page > 0 and limit > 0 do
    offset = (page - 1) * limit
    list |> Enum.drop(offset) |> Enum.take(limit)
  end

  defp paginate_list(_list, _page, _limit), do: []
end
