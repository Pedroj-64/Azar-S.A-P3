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
      {:ok, _} -> {:noreply, reload(socket) |> put_flash(:info, gettext("flash_ticket_bought", number: number))}
      {:error, reason} -> {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("return", %{"number" => num_str}, socket) do
    number = String.to_integer(num_str)
    case CentralServer.return_ticket(socket.assigns.draw_id, socket.assigns.client_id, number) do
      :ok -> {:noreply, reload(socket) |> put_flash(:info, gettext("flash_ticket_returned"))}
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
      <.link navigate={~p"/player/draws"} class="inline-flex items-center gap-2 font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] hover:text-[var(--mostaza)] mb-6 transition-colors">
        <.icon name="hero-arrow-left" class="w-4 h-4" /> {gettext("buy_back")}
      </.link>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <%!-- Draw Info --%>
        <div class="lg:col-span-1">
          <.glass_card>
            <img src={draw_img(@draw)} class="w-full h-40 object-cover mb-4" style="border-radius: 2px; border: 1px solid rgba(212,160,23,0.2);" />
            <h2 class="font-display text-2xl text-[var(--crema)]">{@draw.name}</h2>
            <div class="space-y-2 mt-4 font-mono text-xs text-[var(--crema-oscura)]">
              <p><.icon name="hero-calendar" class="w-4 h-4 inline mr-2" />{@draw.date}</p>
              <p><.icon name="hero-banknotes" class="w-4 h-4 inline mr-2" />{gettext("buy_ticket_label")} ${fmt(@draw.ticket_price)}</p>
              <p><.icon name="hero-squares-2x2" class="w-4 h-4 inline mr-2" />{gettext("buy_fractions_label", count: @draw.fractions)}</p>
              <p><.icon name="hero-ticket" class="w-4 h-4 inline mr-2" />{gettext("buy_total_tickets_label", count: @draw.total_tickets)}</p>
            </div>
            <%!-- Prizes --%>
            <div :if={@draw.prizes != []} class="mt-4 pt-4" style="border-top: 1px solid rgba(212,160,23,0.15);">
              <h4 class="font-mono text-xs uppercase tracking-widest text-[var(--mostaza)] mb-2">{gettext("buy_prizes_section")}</h4>
              <div :for={p <- @draw.prizes} class="flex justify-between font-mono text-sm py-1">
                <span class="text-[var(--crema-oscura)]">{p["name"]}</span>
                <span class="text-[var(--mostaza)]">${fmt(p["amount"] || 0)}</span>
              </div>
            </div>
          </.glass_card>

          <%!-- My Tickets --%>
          <.glass_card class="mt-4">
            <h3 class="font-display text-lg text-[var(--crema)] mb-3">{gettext("my_tickets_title", count: length(@my_tickets))}</h3>
            <div :if={@my_tickets == []} class="font-mono text-xs text-[var(--crema-oscura)]">{gettext("my_tickets_empty")}</div>
            <div :for={t <- @my_tickets} class="flex items-center justify-between p-3 mb-2"
              style="background: rgba(90,46,16,0.2); border-radius: 2px; border: 1px solid rgba(212,160,23,0.08);">
              <div class="flex items-center gap-2">
                <img src={if t["fraction"] == "full", do: ~p"/images/billete_entero.svg", else: ~p"/images/billete_fraccion.svg"} class="w-8 h-5" style="border-radius: 1px;" />
                <span class="text-[var(--crema)] font-mono">#{t["number"]}</span>
                <span class="font-mono text-[0.6rem] text-[var(--crema-oscura)]">({t["fraction"]})</span>
              </div>
              <button phx-click="return" phx-value-number={t["number"]}
                class="font-mono text-[0.65rem] uppercase tracking-widest text-[var(--naranja)] hover:text-red-400 cursor-pointer transition-colors"
                data-confirm={gettext("ticket_return_confirm")}>
                {gettext("ticket_return_btn")}
              </button>
            </div>
          </.glass_card>
        </div>

        <%!-- Number Grid --%>
        <div class="lg:col-span-2">
          <.glass_card>
            <div class="flex items-center justify-between mb-4">
              <h3 class="font-display text-lg text-[var(--crema)]">{gettext("select_number_title")}</h3>
              <div class="flex gap-2">
                <button phx-click="set_mode" phx-value-mode="full"
                  class={["px-3 py-1 font-mono text-[0.65rem] uppercase tracking-widest cursor-pointer transition-all border",
                    if(@buy_mode == "full",
                      do: "text-[var(--teal-lt)] border-[rgba(42,107,107,0.5)] bg-[rgba(42,107,107,0.15)]",
                      else: "text-[var(--crema-oscura)] border-[rgba(212,160,23,0.15)] bg-transparent hover:text-[var(--mostaza)]"
                    )]}>
                  {gettext("buy_mode_full")}
                </button>
                <button :if={@draw.fractions > 1} phx-click="set_mode" phx-value-mode="fraction"
                  class={["px-3 py-1 font-mono text-[0.65rem] uppercase tracking-widest cursor-pointer transition-all border",
                    if(@buy_mode == "fraction",
                      do: "text-[var(--teal-lt)] border-[rgba(42,107,107,0.5)] bg-[rgba(42,107,107,0.15)]",
                      else: "text-[var(--crema-oscura)] border-[rgba(212,160,23,0.15)] bg-transparent hover:text-[var(--mostaza)]"
                    )]}>
                  {gettext("buy_mode_fraction")}
                </button>
              </div>
            </div>

            <div class="grid grid-cols-8 md:grid-cols-10 gap-2 max-h-96 overflow-y-auto p-1">
              <button :for={num <- @available.full}
                phx-click={if @buy_mode == "full", do: "buy", else: "select_number"}
                phx-value-number={num}
                phx-value-fraction="full"
                data-confirm={if @buy_mode == "full", do: gettext("buy_full_confirm", number: num)}
                class="aspect-square flex items-center justify-center text-xs font-mono cursor-pointer transition-all
                       text-[var(--crema-oscura)] hover:text-[var(--mostaza)] hover:halo"
                style="background: rgba(90,46,16,0.25); border: 1px solid rgba(212,160,23,0.1); border-radius: 2px;">
                {num}
              </button>
            </div>

            <%!-- Fraction selector (when mode=fraction and number selected) --%>
            <div :if={@buy_mode == "fraction" && @selected_number} class="mt-4 p-4 page-enter"
              style="background: rgba(90,46,16,0.2); border-radius: 2px; border: 1px solid rgba(212,160,23,0.12);">
              <p class="text-[var(--crema)] text-sm mb-3">
                {gettext("fraction_of_number")} <span class="font-display text-[var(--teal-lt)]">#{@selected_number}</span>:
              </p>
              <div class="flex gap-2 flex-wrap">
                <button :for={frac <- Map.get(@available.fractions, @selected_number, [])}
                  phx-click="buy" phx-value-number={@selected_number} phx-value-fraction={to_string(frac)}
                  data-confirm={gettext("buy_fraction_confirm", frac: frac, number: @selected_number)}
                  class="px-4 py-2 font-mono text-sm cursor-pointer transition-all text-[var(--teal-lt)]"
                  style="background: rgba(42,107,107,0.12); border: 1px solid rgba(42,107,107,0.3); border-radius: 2px;">
                  {gettext("fraction_btn", frac: frac)}
                </button>
              </div>
            </div>
          </.glass_card>
        </div>
      </div>
    </div>
    """
  end
end
