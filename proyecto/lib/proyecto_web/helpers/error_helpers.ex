defmodule ProyectoWeb.ErrorHelpers do
  @moduledoc """
  Convierte los atoms de error del backend en strings traducidos al idioma activo.

  Reglas:
  - El backend (servicios, servidores, dominio) SOLO retorna atoms, nunca strings.
  - Este módulo es el ÚNICO lugar donde los atoms se convierten a texto para el usuario.
  - Se importa globalmente en todos los LiveViews y componentes desde `proyecto_web.ex`.

  Uso:

      case CentralServer.authenticate_client(doc, pass) do
        {:ok, client} -> ...
        {:error, reason} ->
          {:noreply, put_flash(socket, :error, translate_error(reason))}
      end
  """

  use Gettext, backend: ProyectoWeb.Gettext

  # ── Errores de cliente ────────────────────────────────────────────────────────

  def translate_error(:client_not_found), do: gettext("client_not_found")
  def translate_error(:invalid_password), do: gettext("invalid_password")
  def translate_error(:document_exists), do: gettext("document_exists")
  
  # ── Errores de administrador ──────────────────────────────────────────────────
  
  def translate_error(:admin_not_found), do: gettext("admin_not_found")
  def translate_error(:admin_exists), do: gettext("admin_exists")

  # ── Errores de sorteo ─────────────────────────────────────────────────────────

  def translate_error(:draw_not_found), do: gettext("draw_not_found")
  def translate_error(:draw_not_found_or_crashed), do: gettext("draw_not_found_or_crashed")
  def translate_error(:draw_already_exists), do: gettext("draw_already_exists")
  def translate_error(:draw_already_executed), do: gettext("draw_already_executed")
  def translate_error(:draw_has_prizes), do: gettext("draw_has_prizes")
  def translate_error(:draw_has_tickets), do: gettext("draw_has_tickets")

  # ── Errores de ticket ─────────────────────────────────────────────────────────

  def translate_error(:number_taken), do: gettext("number_taken")
  def translate_error(:fraction_taken), do: gettext("fraction_taken")
  def translate_error(:invalid_number), do: gettext("invalid_number")
  def translate_error(:no_tickets_sold), do: gettext("no_tickets_sold")
  def translate_error(:ticket_not_owned), do: gettext("ticket_not_owned")

  # ── Errores de premio ─────────────────────────────────────────────────────────

  def translate_error(:prize_not_found), do: gettext("prize_not_found")

  # ── Errores de fecha del sistema ──────────────────────────────────────────────

  def translate_error(:invalid_date), do: gettext("invalid_date")
  def translate_error(:date_in_the_past), do: gettext("date_in_the_past")

  # ── Fallback genérico ─────────────────────────────────────────────────────────

  def translate_error(unknown) when is_atom(unknown) do
    gettext("unknown_error") <> " (#{unknown})"
  end

  def translate_error(_), do: gettext("unknown_error")
end
