defmodule ProyectoWeb.Player.BuyTicketLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(%{"id" => draw_id}, _session, socket) do
    draw = CentralServer.get_draw(draw_id)
    {:ok, available} = CentralServer.get_available_numbers(draw_id)
    client_id = socket.assigns.client_id

    my_tickets =
      (draw.tickets || %{})
      |> Enum.filter(fn {_k, t} -> t["client_id"] == client_id end)
      |> Enum.map(fn {_k, t} -> t end)

    {:ok, assign(socket,
      page_title: draw.name,
      draw: draw,
      draw_id: draw_id,
      available: available,
      my_tickets: my_tickets,
      selected_number: nil,
      buy_mode: "full"
    )}
  end

  @impl true
  def handle_event("select_number", %{"number" => num}, socket) do
    {:noreply, assign(socket, selected_number: num)}
  end

  @impl true
  def handle_event("set_mode", %{"mode" => mode}, socket) do
    {:noreply, assign(socket, buy_mode: mode)}
  end

  @impl true
  def handle_event("buy", %{"number" => num_str, "fraction" => frac}, socket) do
    number = String.to_integer(num_str)
    fraction = if frac == "full", do: :full, else: String.to_integer(frac)

    case CentralServer.buy_ticket(socket.assigns.draw_id, socket.assigns.client_id, number, fraction) do
      {:ok, _} -> {:noreply, reload(socket) |> put_flash(:info, "¡Billete ##{number} comprado!")}
      {:error, reason} -> {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("return", %{"number" => num_str}, socket) do
    number = String.to_integer(num_str)
    case CentralServer.return_ticket(socket.assigns.draw_id, socket.assigns.client_id, number) do
      :ok -> {:noreply, reload(socket) |> put_flash(:info, "Billete devuelto")}
      {:error, reason} -> {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  defp reload(socket) do
    draw_id = socket.assigns.draw_id
    draw = CentralServer.get_draw(draw_id)
    {:ok, available} = CentralServer.get_available_numbers(draw_id)
    client_id = socket.assigns.client_id
    my_tickets = (draw.tickets || %{}) |> Enum.filter(fn {_k, t} -> t["client_id"] == client_id end) |> Enum.map(fn {_k, t} -> t end)
    assign(socket, draw: draw, available: available, my_tickets: my_tickets, selected_number: nil)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.link navigate={~p"/player/draws"} class="inline-flex items-center gap-2 text-slate-400 hover:text-white mb-6 transition-colors">
        <.icon name="hero-arrow-left" class="w-4 h-4" /> Volver a sorteos
      </.link>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Draw Info -->
        <div class="lg:col-span-1">
          <.glass_card>
            <img src={draw_img(@draw)} class="w-full h-40 object-cover rounded-xl mb-4" />
            <h2 class="text-2xl font-bold text-white">{@draw.name}</h2>
            <div class="space-y-2 mt-4 text-sm">
              <p class="text-slate-400"><.icon name="hero-calendar" class="w-4 h-4 inline mr-2" />{@draw.date}</p>
              <p class="text-slate-400"><.icon name="hero-banknotes" class="w-4 h-4 inline mr-2" />Billete: ${fmt(@draw.ticket_price)}</p>
              <p class="text-slate-400"><.icon name="hero-squares-2x2" class="w-4 h-4 inline mr-2" />{@draw.fractions} fracciones</p>
              <p class="text-slate-400"><.icon name="hero-ticket" class="w-4 h-4 inline mr-2" />{@draw.total_tickets} billetes</p>
            </div>
            <!-- Prizes -->
            <div :if={@draw.prizes != []} class="mt-4 border-t border-white/10 pt-4">
              <h4 class="text-sm font-bold text-yellow-400 mb-2">Premios</h4>
              <div :for={p <- @draw.prizes} class="flex justify-between text-sm py-1">
                <span class="text-slate-300">{p["name"]}</span>
                <span class="text-yellow-400">${fmt(p["amount"] || 0)}</span>
              </div>
            </div>
          </.glass_card>

          <!-- My Tickets -->
          <.glass_card class="mt-4">
            <h3 class="text-lg font-bold text-white mb-3">Mis Billetes ({length(@my_tickets)})</h3>
            <div :if={@my_tickets == []} class="text-slate-400 text-sm">Aún no has comprado billetes.</div>
            <div :for={t <- @my_tickets} class="flex items-center justify-between p-3 bg-slate-700/30 rounded-lg mb-2">
              <div class="flex items-center gap-2">
                <img src={if t["fraction"] == "full", do: ~p"/images/billete_entero.svg", else: ~p"/images/billete_fraccion.svg"} class="w-8 h-5 rounded" />
                <span class="text-white font-mono">#{t["number"]}</span>
                <span class="text-xs text-slate-400">({t["fraction"]})</span>
              </div>
              <button phx-click="return" phx-value-number={t["number"]}
                class="text-red-400 hover:text-red-300 text-xs cursor-pointer" data-confirm="¿Devolver este billete?">
                Devolver
              </button>
            </div>
          </.glass_card>
        </div>

        <!-- Number Grid -->
        <div class="lg:col-span-2">
          <.glass_card>
            <div class="flex items-center justify-between mb-4">
              <h3 class="text-lg font-bold text-white">Selecciona un Número</h3>
              <div class="flex gap-2">
                <button phx-click="set_mode" phx-value-mode="full"
                  class={["px-3 py-1 rounded-lg text-xs font-semibold cursor-pointer transition", @buy_mode == "full" && "bg-emerald-500 text-white" || "bg-slate-700 text-slate-400"]}>
                  Entero
                </button>
                <button :if={@draw.fractions > 1} phx-click="set_mode" phx-value-mode="fraction"
                  class={["px-3 py-1 rounded-lg text-xs font-semibold cursor-pointer transition", @buy_mode == "fraction" && "bg-emerald-500 text-white" || "bg-slate-700 text-slate-400"]}>
                  Fracción
                </button>
              </div>
            </div>

            <div class="grid grid-cols-8 md:grid-cols-10 gap-2 max-h-96 overflow-y-auto p-1">
              <button :for={num <- @available.full}
                phx-click={if @buy_mode == "full", do: "buy", else: "select_number"}
                phx-value-number={num}
                phx-value-fraction="full"
                data-confirm={if @buy_mode == "full", do: "¿Comprar billete ##{num} completo?"}
                class="aspect-square flex items-center justify-center rounded-lg text-xs font-mono cursor-pointer
                       bg-slate-700/50 border border-white/5 text-slate-300
                       hover:bg-emerald-500/20 hover:border-emerald-400/30 hover:text-emerald-400 transition-all">
                {num}
              </button>
            </div>

            <!-- Fraction selector (when mode=fraction and number selected) -->
            <div :if={@buy_mode == "fraction" && @selected_number} class="mt-4 p-4 bg-slate-700/30 rounded-xl animate-fade-in-up">
              <p class="text-white text-sm mb-3">Fracciones del número <span class="font-bold text-emerald-400">#{@selected_number}</span>:</p>
              <div class="flex gap-2 flex-wrap">
                <button :for={frac <- Map.get(@available.fractions, @selected_number, [])}
                  phx-click="buy" phx-value-number={@selected_number} phx-value-fraction={to_string(frac)}
                  data-confirm={"¿Comprar fracción #{frac} del ##{@selected_number}?"}
                  class="px-4 py-2 rounded-lg bg-emerald-500/20 border border-emerald-400/20 text-emerald-400
                         hover:bg-emerald-500/30 cursor-pointer text-sm font-semibold transition">
                  Fracción {frac}
                </button>
              </div>
            </div>
          </.glass_card>
        </div>
      </div>
    </div>
    """
  end

  defp draw_img(d) do
    p = d.ticket_price || 0
    cond do
      p >= 50_000 -> "/images/sorteo_oro.svg"
      p >= 20_000 -> "/images/sorteo_plata.svg"
      true -> "/images/sorteo_bronce.svg"
    end
  end

  defp fmt(n) when is_integer(n), do: n |> Integer.to_string() |> String.reverse() |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  defp fmt(_), do: "0"
end
