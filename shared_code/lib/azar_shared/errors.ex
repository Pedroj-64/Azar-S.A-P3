defmodule AzarShared.Errors do
  @moduledoc """
  Definiciones de errores personalizados del sistema.

  Define estructuras de error reutilizables en toda la aplicación.
  """

  defmodule ValidationError do
    @moduledoc "Error de validación de datos"
    defexception message: "Validation error", field: nil, code: "VALIDATION_ERROR"
  end

  defmodule NotFoundError do
    @moduledoc "Recurso no encontrado"
    defexception message: "Resource not found", code: "NOT_FOUND"
  end

  defmodule UnauthorizedError do
    @moduledoc "Operación no autorizada"
    defexception message: "Unauthorized", code: "UNAUTHORIZED"
  end

  defmodule ConflictError do
    @moduledoc "Conflicto en la operación"
    defexception message: "Conflict", code: "CONFLICT"
  end

  defmodule InsufficientFundsError do
    @moduledoc "Fondos insuficientes"
    defexception message: "Insufficient funds", code: "INSUFFICIENT_FUNDS"
  end

  defmodule DrawNotAvailableError do
    @moduledoc "Sorteo no disponible para la operación"
    defexception message: "Draw is not available", code: "DRAW_NOT_AVAILABLE"
  end

  defmodule TicketNotAvailableError do
    @moduledoc "Billete no disponible"
    defexception message: "Ticket is not available", code: "TICKET_NOT_AVAILABLE"
  end

  defmodule FileOperationError do
    @moduledoc "Error en operación de archivo"
    defexception message: "File operation error", code: "FILE_ERROR"
  end

  @doc """
  Crea un error de validación formateado.

  Retorna un mapa con estructura estándar de error.

  Ejemplo:
    Errors.validation_error("email", "Email inválido")
  """
  @spec validation_error(String.t(), String.t()) :: map()
  def validation_error(field, message) do
    %{
      status: "error",
      code: "VALIDATION_ERROR",
      field: field,
      message: message,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Crea un error genérico formateado.

  Retorna un mapa con estructura estándar de error.

  Ejemplo:
    Errors.error("DRAW_NOT_FOUND", "El sorteo no existe")
  """
  @spec error(String.t(), String.t()) :: map()
  def error(code, message) do
    %{
      status: "error",
      code: code,
      message: message,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Crea una respuesta de éxito formateada.

  Ejemplo:
    Errors.success("Operación completada", %{id: "123"})
  """
  @spec success(String.t(), any()) :: map()
  def success(message, data \\ nil) do
    %{
      status: "success",
      message: message,
      data: data,
      timestamp: DateTime.utc_now()
    }
  end

  @doc """
  Normaliza diferentes tipos de errores a formato estándar.

  Puede recibir:
  - Exception: módulo de excepción
  - String: mensaje de error
  - Map: mapa de error ya formateado
  """
  @spec normalize_error(any()) :: map()
  def normalize_error(%ValidationError{message: msg, field: field}) do
    validation_error(field, msg)
  end

  def normalize_error(%_{message: msg, code: code}) do
    error(code, msg)
  end

  def normalize_error(error_message) when is_binary(error_message) do
    error("INTERNAL_ERROR", error_message)
  end

  def normalize_error(%{status: "error"} = error_map) do
    error_map
  end

  def normalize_error(error) do
    error("INTERNAL_ERROR", "Error desconocido: #{inspect(error)}")
  end
end
