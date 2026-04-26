defmodule AzarShared.Utils.DateHelpers do
  @moduledoc """
  Funciones auxiliares para manejo de fechas.

  Contiene utilidades para:
  - Formateo de fechas
  - Comparación de fechas
  - Cálculos de diferencias temporales
  """

  @doc """
  Formatea un DateTime a string en formato ISO 8601.

  Ejemplo: "2026-04-26T10:30:00Z"
  """
  @spec format_datetime(DateTime.t()) :: String.t()
  def format_datetime(datetime) when is_struct(datetime, DateTime) do
    DateTime.to_iso8601(datetime)
  end

  def format_datetime(_), do: ""

  @doc """
  Convierte un string ISO 8601 a DateTime.

  Retorna: {:ok, DateTime.t()} o {:error, String.t()}
  """
  @spec parse_datetime(String.t()) :: {:ok, DateTime.t(), integer()} | {:error, atom()}
  def parse_datetime(datetime_string) when is_binary(datetime_string) do
    DateTime.from_iso8601(datetime_string)
  end

  def parse_datetime(_), do: {:error, :invalid_format}

  @doc """
  Verifica si una fecha ya pasó.

  Retorna true si la fecha es anterior a ahora, false si es futura o igual.
  """
  @spec is_past_date(DateTime.t()) :: boolean()
  def is_past_date(date) when is_struct(date, DateTime) do
    DateTime.compare(date, DateTime.utc_now()) == :lt
  end

  def is_past_date(_), do: false

  @doc """
  Verifica si una fecha es futura.

  Retorna true si la fecha es posterior a ahora, false si es pasada o igual.
  """
  @spec is_future_date(DateTime.t()) :: boolean()
  def is_future_date(date) when is_struct(date, DateTime) do
    DateTime.compare(date, DateTime.utc_now()) == :gt
  end

  def is_future_date(_), do: false

  @doc """
  Calcula cuántos días faltan para una fecha.

  Retorna número positivo si es futura, negativo si es pasada.
  """
  @spec days_until(DateTime.t()) :: integer()
  def days_until(date) when is_struct(date, DateTime) do
    now = DateTime.utc_now()
    diff_seconds = DateTime.diff(date, now)
    div(diff_seconds, 86400)  # 86400 segundos en un día
  end

  def days_until(_), do: 0

  @doc """
  Calcula la diferencia en segundos entre dos fechas.

  Retorna: fecha1 - fecha2 en segundos
  """
  @spec date_difference(DateTime.t(), DateTime.t()) :: integer()
  def date_difference(date1, date2) when is_struct(date1, DateTime) and is_struct(date2, DateTime) do
    DateTime.diff(date1, date2)
  end

  def date_difference(_, _), do: 0

  @doc """
  Suma días a una fecha.

  Retorna una nueva DateTime con los días sumados.
  """
  @spec add_days(DateTime.t(), integer()) :: DateTime.t()
  def add_days(date, days) when is_struct(date, DateTime) and is_integer(days) do
    seconds = days * 86400
    DateTime.add(date, seconds, :second)
  end

  def add_days(date, _), do: date

  @doc """
  Obtiene solo la fecha (sin hora) en formato YYYY-MM-DD.

  Ejemplo: "2026-04-26"
  """
  @spec format_date_only(DateTime.t()) :: String.t()
  def format_date_only(datetime) when is_struct(datetime, DateTime) do
    DateTime.to_date(datetime)
    |> Date.to_iso8601()
  end

  def format_date_only(_), do: ""

  @doc """
  Obtiene solo la hora (sin fecha) en formato HH:MM:SS.

  Ejemplo: "10:30:45"
  """
  @spec format_time_only(DateTime.t()) :: String.t()
  def format_time_only(datetime) when is_struct(datetime, DateTime) do
    time = DateTime.to_time(datetime)
    Time.to_iso8601(time)
  end

  def format_time_only(_), do: ""

  @doc """
  Verifica si dos fechas son del mismo día.

  Retorna true si ambas fechas están en el mismo día calendario.
  """
  @spec same_day?(DateTime.t(), DateTime.t()) :: boolean()
  def same_day?(date1, date2) when is_struct(date1, DateTime) and is_struct(date2, DateTime) do
    DateTime.to_date(date1) == DateTime.to_date(date2)
  end

  def same_day?(_, _), do: false

  @doc """
  Obtiene una DateTime con la hora al inicio del día (00:00:00).
  """
  @spec start_of_day(DateTime.t()) :: DateTime.t()
  def start_of_day(datetime) when is_struct(datetime, DateTime) do
    datetime
    |> DateTime.to_date()
    |> DateTime.new!(~T[00:00:00], datetime.time_zone)
  end

  def start_of_day(datetime), do: datetime

  @doc """
  Obtiene una DateTime con la hora al final del día (23:59:59).
  """
  @spec end_of_day(DateTime.t()) :: DateTime.t()
  def end_of_day(datetime) when is_struct(datetime, DateTime) do
    datetime
    |> DateTime.to_date()
    |> DateTime.new!(~T[23:59:59], datetime.time_zone)
  end

  def end_of_day(datetime), do: datetime
end
