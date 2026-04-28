defmodule AzarServer.Views.AuditJSON do
  @moduledoc """
  JSON view para respuestas de Auditoría.

  Proporciona funciones para formatear datos de logs
  en respuestas JSON consistentes.
  """

  def index(%{logs: logs}) do
    %{
      status: "ok",
      data: Enum.map(logs, &log_data/1)
    }
  end

  def show(%{log: log}) do
    %{
      status: "ok",
      data: log_data(log)
    }
  end

  defp log_data(log) do
    %{
      id: log.id,
      action: log.action,
      entity_type: log.entity_type,
      entity_id: log.entity_id,
      user_id: log.user_id,
      user_name: log.user_name,
      user_role: log.user_role,
      description: log.description,
      ip_address: log.ip_address,
      status: log.status,
      error_message: log.error_message,
      timestamp: log.timestamp
    }
  end
end
