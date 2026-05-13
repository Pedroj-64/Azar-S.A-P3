defmodule ProyectoWeb.Admin.DateLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Support.SystemDate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket,
      page_title: gettext("date_title"),
      current_date: SystemDate.get_date(),
      executed_draws: nil
    )}
  end

  @impl true
  def handle_event("advance_date", %{"new_date" => new_date}, socket) do
    case SystemDate.advance_date(new_date) do
      {:ok, executed} ->
        {:noreply, socket
         |> assign(current_date: new_date, executed_draws: executed)
         |> put_flash(:info, gettext("flash_date_advanced", count: length(executed)))}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title={gettext("date_title")} subtitle={gettext("date_subtitle")} />
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <.glass_card>
          <div class="text-center">
            <img src={~p"/images/admin_system.svg"} class="w-48 h-32 mx-auto mb-6 opacity-60" style="border-radius: 2px;" />
            <p class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] mb-2">{gettext("date_current_label")}</p>
            <p class="font-display text-5xl text-[var(--crema)] neon-gold mb-2">{@current_date}</p>
          </div>
        </.glass_card>
        <.glass_card>
          <h3 class="font-display text-xl text-[var(--crema)] mb-6">
            <.icon name="hero-forward" class="w-6 h-6 inline mr-2 text-[var(--mostaza)]" /> {gettext("date_advance_title")}
          </h3>
          <form phx-submit="advance_date" class="space-y-6">
            <.glass_input name="new_date" type="date" label={gettext("date_field_label")} required={true} />
            <.gold_button type="submit" class="w-full justify-center">{gettext("date_advance_btn")}</.gold_button>
          </form>
        </.glass_card>
      </div>
      <div :if={@executed_draws} class="mt-8 page-enter">
        <.glass_card>
          <h3 class="font-display text-lg text-[var(--crema)] mb-4">{gettext("date_executed_title")}</h3>
          <div :if={@executed_draws == []} class="font-mono text-xs text-[var(--crema-oscura)]">{gettext("date_executed_empty")}</div>
          <div :for={{draw_id, result} <- @executed_draws} class="p-3 mb-2 flex justify-between"
            style="border-radius: 2px; background: rgba(90,46,16,0.2); border: 1px solid rgba(212,160,23,0.08);">
            <span class="text-[var(--crema)] font-mono text-sm">{draw_id}</span>
            <span :if={match?({:ok, _}, result)} class="font-mono text-xs text-[var(--teal-lt)]">✓ OK</span>
            <span :if={match?({:error, _}, result)} class="font-mono text-xs text-[var(--naranja)]">✗ Error</span>
          </div>
        </.glass_card>
      </div>
    </div>
    """
  end
end
