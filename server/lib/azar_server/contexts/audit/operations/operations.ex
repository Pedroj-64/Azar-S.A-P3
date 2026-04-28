defmodule AzarServer.Contexts.Audit.Operations do
  @moduledoc """
  Operaciones de auditoría del sistema.

  Registra todas las acciones importantes en el sistema para:
  - Trazabilidad de operaciones
  - Seguridad y compliance
  - Debugging y análisis
  - Reportes de actividad

  Acciones registradas:
  - "create": creación de entidades (sorteos, premios, usuarios)
  - "update": modificación de entidades
  - "delete": eliminación de entidades
  - "buy": compra de billetes/fracciones
  - "return": devolución de billetes/fracciones
  - "execute": ejecución de sorteos

  Entidades auditadas:
  - "draw": sorteo
  - "ticket": billete
  - "fraction": fracción
  - "prize": premio
  - "user": usuario
  - "audit": operación de auditoría
  """

  alias AzarServer.Contexts.Audit.AuditLog
  alias AzarShared.Utils.JsonHelper

  @audit_file "priv/data/audit_logs.json"

  @doc """
  Registra una acción de auditoría.

  Parámetros:
  - action: tipo de acción ("create", "update", "delete", "buy", "return", "execute")
  - entity_type: tipo de entidad ("draw", "ticket", "prize", "user")
  - entity_id: ID de la entidad afectada
  - user_id: ID del usuario que realizó la acción
  - user_name: nombre del usuario
  - description: descripción legible de lo que sucedió

  Parámetros opcionales:
  - user_role: rol del usuario ("admin", "player", "system", default: "system")
  - ip_address: dirección IP desde donde se realizó la acción
  - old_value: valor anterior (para updates)
  - new_value: valor nuevo (para updates)
  - status: "success" (default) o "failed"
  - error_message: mensaje de error si aplica

  Retorna:
  - :ok si el registro fue exitoso
  - {:error, reason} si hay problema
  """
  @spec log_action(
    String.t(),
    String.t(),
    String.t(),
    String.t(),
    String.t(),
    String.t(),
    keyword()
  ) :: :ok | {:error, String.t()}
  def log_action(action, entity_type, entity_id, user_id, user_name, description, opts \\ []) do
    attrs = %{
      action: action,
      entity_type: entity_type,
      entity_id: entity_id,
      user_id: user_id,
      user_name: user_name,
      user_role: Keyword.get(opts, :user_role, "system"),
      description: description,
      ip_address: Keyword.get(opts, :ip_address),
      old_value: Keyword.get(opts, :old_value),
      new_value: Keyword.get(opts, :new_value),
      status: Keyword.get(opts, :status, "success"),
      error_message: Keyword.get(opts, :error_message),
      remarks: Keyword.get(opts, :remarks)
    }

    audit_log = AuditLog.new(attrs)

    case JsonHelper.append_to_json_array(@audit_file, audit_log) do
      :ok -> :ok
      error -> error
    end
  end

  @doc """
  Obtiene un registro de auditoría por ID.

  Retorna:
  - {:ok, audit_log} si existe
  - {:error, reason} si no existe o hay problema
  """
  @spec get_audit_log(String.t()) :: {:ok, AuditLog.t()} | {:error, String.t()}
  def get_audit_log(log_id) do
    case JsonHelper.get_from_json(@audit_file, log_id) do
      {:ok, log_data} -> {:ok, AuditLog.new(log_data)}
      error -> error
    end
  end

  @doc """
  Lista registros de auditoría con filtros opcionales.

  Parámetros opcionales (via keyword list):
  - action: filtrar por tipo de acción
  - entity_type: filtrar por tipo de entidad
  - user_id: filtrar por usuario
  - entity_id: filtrar por entidad específica
  - status: filtrar por "success" o "failed"
  - limit: cantidad máxima de registros (default: todos)
  - offset: saltar N registros (default: 0)

  Ejemplo:
    list_audit_logs(action: "buy", user_id: "user-123", limit: 50)

  Retorna lista ordenada por timestamp descendente (más recientes primero).
  """
  @spec list_audit_logs(keyword()) :: {:ok, [AuditLog.t()]} | {:error, String.t()}
  def list_audit_logs(opts \\ []) do
    case JsonHelper.read_json(@audit_file) do
      {:ok, logs} ->
        filtered_logs =
          logs
          |> Enum.filter(&matches_all_filters(&1, opts))
          |> Enum.sort_by(fn log ->
            DateTime.to_unix(log["timestamp"] || DateTime.utc_now())
          end, :desc)
          |> apply_limit_offset(opts)
          |> Enum.map(&AuditLog.new/1)

        {:ok, filtered_logs}

      error ->
        error
    end
  end

  @doc """
  Lista registros de auditoría por entidad específica.

  Útil para rastrear el historial de cambios de una entidad.

  Retorna registros ordenados por timestamp descendente.
  """
  @spec entity_history(String.t(), String.t()) :: {:ok, [AuditLog.t()]} | {:error, String.t()}
  def entity_history(entity_type, entity_id) do
    list_audit_logs(entity_type: entity_type, entity_id: entity_id)
  end

  @doc """
  Lista registros de auditoría por usuario.

  Útil para auditar actividad de un usuario específico.
  """
  @spec user_activity(String.t()) :: {:ok, [AuditLog.t()]} | {:error, String.t()}
  def user_activity(user_id) do
    list_audit_logs(user_id: user_id)
  end

  @doc """
  Cuenta registros de auditoría con filtros opcionales.

  Soporta los mismos filtros que list_audit_logs/1.

  Retorna cantidad de registros que coinciden.
  """
  @spec count_audit_logs(keyword()) :: {:ok, integer()} | {:error, String.t()}
  def count_audit_logs(opts \\ []) do
    case JsonHelper.read_json(@audit_file) do
      {:ok, logs} ->
        count =
          logs
          |> Enum.filter(&matches_all_filters(&1, opts))
          |> length()

        {:ok, count}

      error ->
        error
    end
  end

  @doc """
  Exporta registros de auditoría para reportes.

  Parámetros:
  - format: :json (default), :csv, :csv_file
  - opts: filtros adicionales (same as list_audit_logs)

  Si format es :csv_file, incluir path: "archivo.csv" en opts.

  Retorna:
  - {:ok, data} con los registros en el formato solicitado
  - {:error, reason} si hay problema
  """
  @spec export_audit_logs(atom(), keyword()) :: {:ok, any()} | {:error, String.t()}
  def export_audit_logs(format \\ :json, opts \\ []) do
    with {:ok, logs} <- list_audit_logs(opts) do
      case format do
        :json ->
          {:ok, Enum.map(logs, &to_map/1)}

        :csv ->
          csv_data = logs_to_csv(logs)
          {:ok, csv_data}

        :csv_file ->
          path = Keyword.get(opts, :path, "audit_export.csv")
          csv_data = logs_to_csv(logs)
          File.write!(path, csv_data)
          {:ok, path}

        _ ->
          {:error, "Formato no soportado"}
      end
    end
  end

  @doc """
  Limpia registros de auditoría antiguos.

  Parámetros:
  - days: cantidad de días a mantener (default: 365)

  Elimina registros más antiguos que la fecha especificada.
  """
  @spec cleanup_old_logs(integer()) :: {:ok, integer()} | {:error, String.t()}
  def cleanup_old_logs(days \\ 365) do
    cutoff_date = DateTime.add(DateTime.utc_now(), -days * 24 * 3600)

    case JsonHelper.read_json(@audit_file) do
      {:ok, logs} ->
        remaining_logs =
          Enum.filter(logs, fn log ->
            log_timestamp = log["timestamp"] || DateTime.utc_now()
            DateTime.compare(log_timestamp, cutoff_date) == :gt
          end)

        deleted_count = length(logs) - length(remaining_logs)

        # Reescribir archivo con logs restantes
        case File.write(@audit_file, Jason.encode!(remaining_logs, pretty: true)) do
          :ok -> {:ok, deleted_count}
          error -> error
        end

      error ->
        error
    end
  end

  # ============================================================================
  # HELPERS PRIVADOS
  # ============================================================================

  defp matches_all_filters(log, opts) do
    Enum.all?(opts, fn {key, value} ->
      matches_filter(log, key, value)
    end)
  end

  defp matches_filter(_log, :limit, _), do: true
  defp matches_filter(_log, :offset, _), do: true

  defp matches_filter(log, :action, value), do: log["action"] == value
  defp matches_filter(log, :entity_type, value), do: log["entity_type"] == value
  defp matches_filter(log, :user_id, value), do: log["user_id"] == value
  defp matches_filter(log, :entity_id, value), do: log["entity_id"] == value
  defp matches_filter(log, :status, value), do: log["status"] == value
  defp matches_filter(_log, _key, _value), do: true

  defp apply_limit_offset(logs, opts) do
    limit = Keyword.get(opts, :limit, nil)
    offset = Keyword.get(opts, :offset, 0)

    logs = Enum.drop(logs, offset)

    if limit do
      Enum.take(logs, limit)
    else
      logs
    end
  end

  defp to_map(audit_log) do
    %{
      id: audit_log.id,
      action: audit_log.action,
      entity_type: audit_log.entity_type,
      entity_id: audit_log.entity_id,
      user_id: audit_log.user_id,
      user_name: audit_log.user_name,
      user_role: audit_log.user_role,
      timestamp: audit_log.timestamp,
      description: audit_log.description,
      status: audit_log.status,
      error_message: audit_log.error_message
    }
  end

  defp logs_to_csv(logs) do
    headers = ["ID", "Action", "Entity Type", "Entity ID", "User ID", "User Name", "Role", "Timestamp", "Description", "Status"]
    header_row = Enum.join(headers, ",")

    data_rows =
      Enum.map(logs, fn log ->
        values = [
          log.id,
          log.action,
          log.entity_type,
          log.entity_id || "",
          log.user_id,
          log.user_name,
          log.user_role,
          DateTime.to_iso8601(log.timestamp),
          log.description,
          log.status
        ]

        values
        |> Enum.map(&escape_csv_value/1)
        |> Enum.join(",")
      end)

    [header_row | data_rows] |> Enum.join("\n")
  end

  defp escape_csv_value(value) when is_binary(value) do
    if String.contains?(value, [",", "\"", "\n"]) do
      "\"#{String.replace(value, "\"", "\"\"")}\""
    else
      value
    end
  end

  defp escape_csv_value(value), do: to_string(value)
end
