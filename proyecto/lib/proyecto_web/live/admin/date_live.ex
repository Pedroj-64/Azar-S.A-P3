defmodule ProyectoWeb.Admin.DateLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Support.SystemDate

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Fecha", current_date: SystemDate.get_date(), executed_draws: nil)}
  end

  @impl true
  def handle_event("advance_date", %{"new_date" => new_date}, socket) do
    case SystemDate.advance_date(new_date) do
      {:ok, executed} ->
        {:noreply, socket |> assign(current_date: new_date, executed_draws: executed)
         |> put_flash(:info, "Fecha avanzada. #{length(executed)} sorteo(s) ejecutado(s).")}
      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title="Fecha del Sistema" subtitle="Simula el paso del tiempo" />
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <.glass_card>
          <div class="text-center">
            <img src={~p"/images/admin_system.svg"} class="w-48 h-32 mx-auto mb-6 rounded-xl opacity-60" />
            <p class="text-slate-400 text-sm mb-2">Fecha actual</p>
            <p class="text-5xl font-black text-white mb-2">{@current_date}</p>
          </div>
        </.glass_card>
        <.glass_card>
          <h3 class="text-xl font-bold text-white mb-6">
            <.icon name="hero-forward" class="w-6 h-6 inline mr-2 text-yellow-400" /> Avanzar
          </h3>
          <form phx-submit="advance_date" class="space-y-6">
            <.glass_input name="new_date" type="date" label="Nueva fecha" required={true} />
            <.gold_button type="submit" class="w-full justify-center">Avanzar Fecha</.gold_button>
          </form>
        </.glass_card>
      </div>
      <div :if={@executed_draws} class="mt-8 animate-fade-in-up">
        <.glass_card>
          <h3 class="text-lg font-bold text-white mb-4">Sorteos Ejecutados</h3>
          <div :if={@executed_draws == []} class="text-slate-400 text-sm">Ningún sorteo pendiente.</div>
          <div :for={{draw_id, result} <- @executed_draws} class="p-3 rounded-xl bg-slate-700/30 mb-2 flex justify-between">
            <span class="text-white">{draw_id}</span>
            <span :if={match?({:ok, _}, result)} class="text-emerald-400 text-sm">✓ OK</span>
            <span :if={match?({:error, _}, result)} class="text-red-400 text-sm">✗ Error</span>
          </div>
        </.glass_card>
      </div>
    </div>
    """
  end
end
