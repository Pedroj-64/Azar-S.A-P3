defmodule AzarServer.Controllers.AuditController do
  @moduledoc """
  Controller para consulta de logs de auditoría.

  Proporciona endpoints para:
  - Listar logs de auditoría
  - Filtrar por entidad, usuario, acción
  - Obtener detalles de un log específico
  - Generar reportes de auditoría
  """

  use Phoenix.Controller

  alias AzarServer.Contexts.Audit.Operations, as: AuditOps

  @doc """
  Lista todos los logs de auditoría.

  Parámetros:
  - action: String (opcional: "create", "update", "delete", "buy", "return", "execute")
  - entity_type: String (opcional: "draw", "ticket", "prize", "user")
  - entity_id: String (opcional)
  - user_id: String (opcional)
  - status: String (opcional: "success", "failed")
  - page: Integer (default: 1)
  - limit: Integer (default: 50, máximo 200)

  Retorna:
  - 200 OK: Lista paginada de logs
  """
  def list(conn, params) do
    page = String.to_integer(params["page"] || "1")
    limit = String.to_integer(params["limit"] || "50") |> min(200)

    filters = %{
      action: params["action"],
      entity_type: params["entity_type"],
      entity_id: params["entity_id"],
      user_id: params["user_id"],
      status: params["status"]
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Enum.into(%{})

    case AuditOps.list_audit_logs(filters) do
      {:ok, logs} ->
        paginated = paginate_list(logs, page, limit)

        json(conn, %{
          status: "ok",
          logs: Enum.map(paginated, &format_log_response/1),
          page: page,
          limit: limit,
          total: Enum.count(logs),
          filters: filters
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
  Obtiene logs por entidad específica.

  Parámetros:
  - entity_type: String ("draw", "ticket", "prize", "user")
  - entity_id: String (ID de la entidad)

  Retorna:
  - 200 OK: Historial completo de cambios en la entidad
  """
  def by_entity(conn, %{"entity_type" => entity_type, "entity_id" => entity_id}) do
    case AuditOps.get_entity_history(entity_type, entity_id) do
      {:ok, logs} ->
        json(conn, %{
          status: "ok",
          entity_type: entity_type,
          entity_id: entity_id,
          changes: Enum.map(logs, &format_log_response/1),
          total: Enum.count(logs)
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
  Obtiene logs por usuario específico.

  Parámetros:
  - user_id: String (ID del usuario)
  - action: String (opcional)

  Retorna:
  - 200 OK: Actividad del usuario
  """
  def by_user(conn, %{"user_id" => user_id}) do
    action = conn.params["action"]

    case AuditOps.get_user_activity(user_id, action) do
      {:ok, logs} ->
        json(conn, %{
          status: "ok",
          user_id: user_id,
          activity: Enum.map(logs, &format_log_response/1),
          total: Enum.count(logs)
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
  Obtiene detalles de un log específico.

  Retorna:
  - 200 OK: Detalles del log
  - 404 Not Found: Log no existe
  """
  def show(conn, %{"id" => log_id}) do
    case AuditOps.get_audit_log(log_id) do
      {:ok, log} ->
        json(conn, %{
          status: "ok",
          log: format_log_response(log)
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
  Genera reporte de auditoría por período.

  Parámetros:
  - from_date: DateTime (fecha inicio)
  - to_date: DateTime (fecha fin)
  - group_by: String (opcional: "action", "entity_type", "user")

  Retorna:
  - 200 OK: Reporte con estadísticas
  """
  def report(conn, params) do
    from_date = params["from_date"]
    to_date = params["to_date"]
    group_by = params["group_by"] || "action"

    case validate_date_params(from_date, to_date) do
      {:ok, {from, to}} ->
        case AuditOps.generate_audit_report(from, to, group_by) do
          {:ok, report} ->
            json(conn, %{
              status: "ok",
              report: report,
              period: %{
                from: from,
                to: to
              },
              grouped_by: group_by
            })

          {:error, reason} ->
            conn
            |> put_status(:internal_server_error)
            |> json(%{
              status: "error",
              message: reason
            })
        end

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
  Obtiene resumen de auditoría (últimas 24 horas).

  Retorna:
  - 200 OK: Resumen de actividad reciente
  """
  def summary(conn, _params) do
    case AuditOps.get_audit_summary() do
      {:ok, summary} ->
        json(conn, %{
          status: "ok",
          summary: summary
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

  # Helpers

  defp format_log_response(log) do
    %{
      id: log.id,
      action: log.action,
      entity_type: log.entity_type,
      entity_id: log.entity_id,
      user_id: log.user_id,
      user_name: log.user_name,
      user_role: log.user_role,
      description: log.description,
      status: log.status,
      error_message: log.error_message,
      ip_address: log.ip_address,
      old_value: log.old_value,
      new_value: log.new_value,
      created_at: log.created_at,
      remarks: log.remarks
    }
  end

  defp paginate_list(list, page, limit) when page > 0 and limit > 0 do
    offset = (page - 1) * limit
    list |> Enum.drop(offset) |> Enum.take(limit)
  end

  defp paginate_list(_list, _page, _limit), do: []

  defp validate_date_params(from_date, to_date) when is_binary(from_date) and is_binary(to_date) do
    case {DateTime.from_iso8601(from_date), DateTime.from_iso8601(to_date)} do
      {{:ok, from, _}, {:ok, to, _}} ->
        if DateTime.compare(from, to) == :lt do
          {:ok, {from, to}}
        else
          {:error, "from_date must be before to_date"}
        end

      _ ->
        {:error, "Invalid date format. Use ISO8601 format."}
    end
  end

  defp validate_date_params(_, _) do
    {:error, "Both from_date and to_date are required"}
  end
end
