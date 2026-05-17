defmodule ProyectoWeb.Admin.DrawsLive do
  @moduledoc """
  Gestión de sorteos: listar, crear, agregar premios, ejecutar y eliminar.
  También permite consultar clientes de un sorteo y ver ganadores por premio.
  Incluye sorting por fecha, nombre, precio, estado y número de premios.
  """
  use ProyectoWeb, :live_view

  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    draws = CentralServer.list_draws()

    {:ok,
     assign(socket,
       page_title: gettext("draws_title"),
       draws: draws,
       sorted_draws: sort_draws(draws, "date", "asc"),
       sort_by: "date",
       sort_dir: "asc",
       show_create: false,
       show_prizes: nil,
       show_clients: nil,
       draw_clients: nil,
       clients_sort: "name",
       prize_draw_id: nil
     )}
  end

  # ── Sorting ───────────────────────────────────────────────

  @impl true
  def handle_event("sort", %{"by" => field}, socket) do
    current = socket.assigns.sort_by
    current_dir = socket.assigns.sort_dir

    # Toggle direction if same field, otherwise default to asc
    new_dir = if field == current and current_dir == "asc", do: "desc", else: "asc"
    sorted = sort_draws(socket.assigns.draws, field, new_dir)

    {:noreply, assign(socket, sorted_draws: sorted, sort_by: field, sort_dir: new_dir)}
  end

  # ── Create / Run / Delete ─────────────────────────────────

  @impl true
  def handle_event("toggle_create", _params, socket) do
    {:noreply, assign(socket, show_create: !socket.assigns.show_create)}
  end

  @impl true
  def handle_event("create_draw", params, socket) do
    draw_id = "draw_" <> (:crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower))

    case CentralServer.create_draw(
           draw_id,
           params["name"],
           params["date"],
           String.to_integer(params["ticket_price"] || "10000"),
           String.to_integer(params["fractions"] || "1"),
           String.to_integer(params["total_tickets"] || "100")
         ) do
      {:ok, _id} ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws, sorted_draws: sort_draws(draws, socket.assigns.sort_by, socket.assigns.sort_dir), show_create: false)
         |> put_flash(:info, gettext("flash_draw_created"))}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("run_draw", %{"id" => draw_id}, socket) do
    case CentralServer.run_draw(draw_id) do
      {:ok, result} ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws, sorted_draws: sort_draws(draws, socket.assigns.sort_by, socket.assigns.sort_dir))
         |> put_flash(:info, gettext("flash_draw_run", number: result["winner_number"]))}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("delete_draw", %{"id" => draw_id}, socket) do
    case CentralServer.delete_draw(draw_id) do
      :ok ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws, sorted_draws: sort_draws(draws, socket.assigns.sort_by, socket.assigns.sort_dir))
         |> put_flash(:info, gettext("flash_draw_deleted"))}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  # ── Prizes ────────────────────────────────────────────────

  @impl true
  def handle_event("show_prizes", %{"id" => draw_id}, socket) do
    {:noreply, assign(socket, show_prizes: draw_id)}
  end

  @impl true
  def handle_event("hide_prizes", _params, socket) do
    {:noreply, assign(socket, show_prizes: nil)}
  end

  @impl true
  def handle_event("add_prize", %{"draw_id" => draw_id, "name" => name, "amount" => amount}, socket) do
    case CentralServer.add_prize(draw_id, name, String.to_integer(amount)) do
      {:ok, _prize} ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws, sorted_draws: sort_draws(draws, socket.assigns.sort_by, socket.assigns.sort_dir))
         |> put_flash(:info, gettext("flash_prize_added"))}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("delete_prize", %{"draw_id" => draw_id, "prize_id" => prize_id}, socket) do
    case CentralServer.delete_prize(draw_id, prize_id) do
      :ok ->
        draws = CentralServer.list_draws()
        {:noreply, socket |> assign(draws: draws, sorted_draws: sort_draws(draws, socket.assigns.sort_by, socket.assigns.sort_dir)) |> put_flash(:info, gettext("flash_prize_deleted"))}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  # ── Clients ───────────────────────────────────────────────

  @impl true
  def handle_event("show_clients", %{"id" => draw_id}, socket) do
    draw = Enum.find(socket.assigns.draws, fn d -> d["id"] == draw_id end)
    tickets = draw["tickets"] || %{}

    # Build detailed client info with ticket counts
    client_details =
      tickets
      |> Map.values()
      |> Enum.group_by(fn t -> t["client_id"] end)
      |> Enum.map(fn {client_id, client_tickets} ->
        full_count = Enum.count(client_tickets, fn t -> t["fraction"] == "full" end)
        frac_count = Enum.count(client_tickets, fn t -> t["fraction"] != "full" end)
        name = AzarSa.Core.Services.DrawService.resolve_client_name(client_id)
        %{id: client_id, name: name, full_tickets: full_count, fraction_tickets: frac_count, total: length(client_tickets)}
      end)
      |> Enum.sort_by(fn c -> c.name end)

    {:noreply, assign(socket, show_clients: draw_id, draw_clients: client_details)}
  end

  @impl true
  def handle_event("hide_clients", _params, socket) do
    {:noreply, assign(socket, show_clients: nil, draw_clients: nil)}
  end

  @impl true
  def handle_event("sort_clients", %{"by" => field}, socket) do
    clients = socket.assigns.draw_clients || []

    sorted = case field do
      "name" -> Enum.sort_by(clients, fn c -> c.name end)
      "tickets" -> Enum.sort_by(clients, fn c -> c.total end, :desc)
      _ -> clients
    end

    {:noreply, assign(socket, draw_clients: sorted, clients_sort: field)}
  end

  # ── Render ────────────────────────────────────────────────

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-8">
        <.page_header title={gettext("draws_title")} subtitle={gettext("draws_subtitle")} />
        <.gold_button phx-click="toggle_create">
          <.icon name="hero-plus" class="w-5 h-5 mr-2 inline" />
          {gettext("draws_new_btn")}
        </.gold_button>
      </div>

      <%!-- Create Form --%>
      <div :if={@show_create} class="mb-8 page-enter">
        <.glass_card>
          <h3 class="font-display text-lg text-[var(--crema)] mb-4">{gettext("create_draw_title")}</h3>
          <form phx-submit="create_draw" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.glass_input name="name" label={gettext("draw_field_name")} placeholder={gettext("draw_field_name_placeholder")} required={true} />
            <.glass_input name="date" type="date" label={gettext("draw_field_date")} required={true} />
            <.glass_input name="ticket_price" type="number" label={gettext("draw_field_price")} placeholder="10000" required={true} />
            <.glass_input name="fractions" type="number" label={gettext("draw_field_fractions")} placeholder="1" required={true} />
            <.glass_input name="total_tickets" type="number" label={gettext("draw_field_total")} placeholder="100" required={true} />
            <div class="flex items-end">
              <.emerald_button type="submit" class="w-full">{gettext("draw_create_btn")}</.emerald_button>
            </div>
          </form>
        </.glass_card>
      </div>

      <%!-- Sort Controls --%>
      <div class="flex items-center gap-2 mb-4 flex-wrap">
        <span class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)] mr-2">
          <.icon name="hero-arrows-up-down" class="w-3 h-3 inline" /> Ordenar:
        </span>
        <.sort_pill active={@sort_by == "date"} dir={@sort_dir} label="Fecha" field="date" />
        <.sort_pill active={@sort_by == "name"} dir={@sort_dir} label="Nombre" field="name" />
        <.sort_pill active={@sort_by == "price"} dir={@sort_dir} label="Precio" field="price" />
        <.sort_pill active={@sort_by == "tickets"} dir={@sort_dir} label="Vendidos" field="tickets" />
        <.sort_pill active={@sort_by == "prizes"} dir={@sort_dir} label="Premios" field="prizes" />
        <.sort_pill active={@sort_by == "status"} dir={@sort_dir} label="Estado" field="status" />
      </div>

      <%!-- Draws List --%>
      <div :if={@sorted_draws == []}>
        <.glass_card>
          <.empty_state icon_name="hero-ticket" message={gettext("draw_empty")} />
        </.glass_card>
      </div>

      <div class="space-y-4">
        <div :for={draw <- @sorted_draws}>
          <.glass_card>
            <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
              <%!-- Draw Info --%>
              <div class="flex items-center gap-4 flex-1">
                <img src={draw_img(draw)} class="w-16 h-16 rounded object-cover" style="border: 1px solid rgba(212,160,23,0.2);" />
                <div>
                  <h3 class="font-display text-lg text-[var(--crema)]">{draw["name"]}</h3>
                  <div class="flex items-center gap-3 mt-1 flex-wrap">
                    <span class="font-mono text-xs text-[var(--crema-oscura)]">
                      <.icon name="hero-calendar" class="w-4 h-4 inline mr-1" />{draw["date"] || gettext("draw_no_date")}
                    </span>
                    <span class="font-mono text-xs text-[var(--crema-oscura)]">
                      <.icon name="hero-banknotes" class="w-4 h-4 inline mr-1" />${fmt(draw["ticket_price"] || 0)}
                    </span>
                    <span class="font-mono text-xs text-[var(--crema-oscura)]" title={"#{count_unique_buyers(draw)} compradores distintos"}>
                      <.icon name="hero-squares-2x2" class="w-4 h-4 inline mr-1" />
                      {gettext("draw_tickets_sold", count: map_size(draw["tickets"] || %{}))}
                      <span class="text-[var(--teal-lt)] ml-1">({count_unique_buyers(draw)} <.icon name="hero-user" class="w-3 h-3 inline" />)</span>
                    </span>
                    <span class="font-mono text-xs text-[var(--mostaza)]">
                      <.icon name="hero-gift" class="w-4 h-4 inline mr-1" />{length(draw["prizes"] || [])} premios
                    </span>
                  </div>
                </div>
              </div>

              <%!-- Actions --%>
              <div class="flex items-center gap-2">
                <.status_badge status={to_string(draw["status"] || "pending")} />

                <.ghost_button
                  phx-click="show_prizes"
                  phx-value-id={draw["id"]}
                >
                  <.icon name="hero-gift" class="w-4 h-4" />
                </.ghost_button>

                <.ghost_button
                  phx-click="show_clients"
                  phx-value-id={draw["id"]}
                >
                  <.icon name="hero-users" class="w-4 h-4" />
                </.ghost_button>

                <.emerald_button
                  :if={to_string(draw["status"]) == "pending"}
                  phx-click="run_draw"
                  phx-value-id={draw["id"]}
                  class="px-4 py-2 text-sm"
                  data-confirm={gettext("draw_run_confirm")}
                >
                  <.icon name="hero-play" class="w-4 h-4 mr-1 inline" /> {gettext("draw_run_btn")}
                </.emerald_button>

                <.danger_button
                  :if={to_string(draw["status"]) == "pending"}
                  phx-click="delete_draw"
                  phx-value-id={draw["id"]}
                  data-confirm={gettext("draw_delete_confirm")}
                >
                  <.icon name="hero-trash" class="w-4 h-4" />
                </.danger_button>
              </div>
            </div>

            <%!-- Result (if done) with per-prize winners --%>
            <div :if={draw["result"]} class="mt-4 p-4" style="border-radius: 2px; background: rgba(42,107,107,0.1); border: 1px solid rgba(42,107,107,0.25);">
              <p class="font-mono text-sm text-[var(--teal-lt)] mb-2">
                <.icon name="hero-trophy" class="w-5 h-5 inline mr-2" />
                {gettext("draw_winner_result",
                  number: draw["result"]["winner_number"],
                  prize: fmt(draw["result"]["total_prize"] || 0)
                )}
              </p>
              <%!-- Winning numbers summary --%>
              <div :if={draw["winning_numbers"] && draw["winning_numbers"] != []} class="mb-2">
                <span class="font-mono text-xs text-[var(--crema-oscura)]">Números ganadores: </span>
                <span :for={wn <- draw["winning_numbers"] || []}
                  class="inline-block px-2 py-0.5 mx-0.5 font-mono text-sm font-bold text-[var(--mostaza)] neon-gold"
                  style="background: rgba(212,160,23,0.12); border: 1px solid rgba(212,160,23,0.3); border-radius: 2px;">
                  #{wn}
                </span>
              </div>
              <%!-- Per-prize winners detail --%>
              <div :if={draw["result"]["prize_winners"]} class="mt-2 space-y-1">
                <div :for={pw <- draw["result"]["prize_winners"] || []}
                  class="flex items-center justify-between py-1.5 px-3 font-mono text-xs"
                  style="background: rgba(42,107,107,0.06); border-radius: 2px;">
                  <span class="text-[var(--crema)]">
                    <.icon name="hero-trophy" class="w-3 h-3 inline mr-1 text-[var(--mostaza)]" />
                    {pw["prize_name"]}
                  </span>
                  <span class="text-[var(--teal-lt)]">
                    # {pw["winner_number"]}
                  </span>
                  <span class="text-[var(--mostaza)] font-bold">${fmt(pw["prize_amount"] || 0)}</span>
                </div>
              </div>
            </div>

            <%!-- Clients Panel (improved with ticket counts) --%>
            <div :if={@show_clients == draw["id"] && @draw_clients} class="mt-4 page-enter">
              <div style="border-top: 1px solid rgba(212,160,23,0.15); padding-top: 1rem;">
                <div class="flex items-center justify-between mb-3">
                  <h4 class="font-mono text-xs uppercase tracking-widest text-[var(--crema)]">
                    <.icon name="hero-users" class="w-4 h-4 inline mr-1" /> {gettext("draw_clients_title")}
                    <span class="text-[var(--mostaza)] ml-1">({length(@draw_clients)})</span>
                  </h4>
                  <div class="flex items-center gap-2">
                    <button phx-click="sort_clients" phx-value-by="name"
                      class={"font-mono text-[0.6rem] uppercase tracking-widest px-2 py-0.5 cursor-pointer transition-colors border rounded-sm " <>
                        if(@clients_sort == "name",
                          do: "text-[var(--mostaza)] border-[rgba(212,160,23,0.4)] bg-[rgba(212,160,23,0.1)]",
                          else: "text-[var(--crema-oscura)] border-transparent hover:text-[var(--mostaza)]"
                        )}>A-Z</button>
                    <button phx-click="sort_clients" phx-value-by="tickets"
                      class={"font-mono text-[0.6rem] uppercase tracking-widest px-2 py-0.5 cursor-pointer transition-colors border rounded-sm " <>
                        if(@clients_sort == "tickets",
                          do: "text-[var(--mostaza)] border-[rgba(212,160,23,0.4)] bg-[rgba(212,160,23,0.1)]",
                          else: "text-[var(--crema-oscura)] border-transparent hover:text-[var(--mostaza)]"
                        )}>Tickets</button>
                    <button phx-click="hide_clients" class="text-[var(--crema-oscura)] hover:text-[var(--mostaza)] cursor-pointer transition-colors">
                      <.icon name="hero-x-mark" class="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <div :if={@draw_clients == []} class="font-mono text-xs text-[var(--crema-oscura)] italic">
                  {gettext("draw_clients_none")}
                </div>

                <div :for={client <- @draw_clients}
                  class="flex items-center justify-between py-2 px-3 mb-1 font-mono text-sm"
                  style="background: rgba(90,46,16,0.2); border-radius: 2px; border: 1px solid rgba(212,160,23,0.08);">
                  <span class="text-[var(--crema)]">{client.name}</span>
                  <div class="flex items-center gap-3">
                    <span :if={client.full_tickets > 0} class="text-[var(--mostaza)] text-xs">
                      {client.full_tickets} billete{if client.full_tickets != 1, do: "s"}
                    </span>
                    <span :if={client.fraction_tickets > 0} class="text-[var(--teal-lt)] text-xs">
                      {client.fraction_tickets} fracción{if client.fraction_tickets != 1, do: "es"}
                    </span>
                    <span class="text-[var(--crema-oscura)] text-xs">
                      ({client.total} total)
                    </span>
                  </div>
                </div>
              </div>
            </div>

            <%!-- Prizes Panel --%>
            <div :if={@show_prizes == draw["id"]} class="mt-4 page-enter">
              <div style="border-top: 1px solid rgba(212,160,23,0.15); padding-top: 1rem;">
                <h4 class="font-mono text-xs uppercase tracking-widest text-[var(--crema)] mb-3">
                  <.icon name="hero-gift" class="w-4 h-4 inline mr-1" /> {gettext("prizes_panel_title", count: length(draw["prizes"] || []))}
                  <button phx-click="hide_prizes" class="ml-2 text-[var(--crema-oscura)] hover:text-[var(--mostaza)] cursor-pointer transition-colors">
                    <.icon name="hero-x-mark" class="w-3 h-3 inline" />
                  </button>
                </h4>

                <div :for={prize <- Enum.sort_by(draw["prizes"] || [], fn p -> -(p["amount"] || 0) end)}
                  class="flex items-center justify-between p-3 mb-2"
                  style="border-radius: 2px; background: rgba(90,46,16,0.2); border: 1px solid rgba(212,160,23,0.08);">
                  <div class="flex-1">
                    <span class="text-[var(--crema)] text-sm">{prize["name"]}</span>
                    <span class="text-[var(--mostaza)] text-sm ml-2 font-bold">${fmt(prize["amount"] || 0)}</span>
                  </div>
                  <button
                    :if={to_string(draw["status"]) == "pending" && map_size(draw["tickets"] || %{}) == 0}
                    phx-click="delete_prize"
                    phx-value-draw_id={draw["id"]}
                    phx-value-prize_id={prize["id"]}
                    class="text-[var(--naranja)] hover:text-red-400 cursor-pointer transition-colors"
                    data-confirm="¿Eliminar este premio?"
                  >
                    <.icon name="hero-x-mark" class="w-4 h-4" />
                  </button>
                  <span
                    :if={to_string(draw["status"]) == "pending" && map_size(draw["tickets"] || %{}) > 0}
                    class="font-mono text-[0.55rem] text-[var(--crema-oscura)] italic"
                  >
                    (clientes asociados)
                  </span>
                </div>

                <%!-- Add Prize Form (fixed widths) --%>
                <form :if={to_string(draw["status"]) == "pending"}
                  phx-submit="add_prize" class="flex gap-2 mt-3 items-end">
                  <input type="hidden" name="draw_id" value={draw["id"]} />
                  <div class="flex-[2]">
                    <label class="font-mono text-[0.55rem] uppercase tracking-widest text-[var(--crema-oscura)] block mb-1">Nombre</label>
                    <input name="name" placeholder={gettext("prize_name_placeholder")} required
                      class="vintage-input w-full" />
                  </div>
                  <div class="flex-1">
                    <label class="font-mono text-[0.55rem] uppercase tracking-widest text-[var(--crema-oscura)] block mb-1">Monto</label>
                    <input name="amount" type="number" placeholder={gettext("prize_amount_placeholder")} required
                      class="vintage-input w-full" />
                  </div>
                  <.gold_button type="submit" class="px-4 py-2 text-sm">{gettext("prize_add_btn")}</.gold_button>
                </form>
              </div>
            </div>
          </.glass_card>
        </div>
      </div>
    </div>
    """
  end

  # ── Sort Pill Component ───────────────────────────────────

  attr :active, :boolean, required: true
  attr :dir, :string, required: true
  attr :label, :string, required: true
  attr :field, :string, required: true

  defp sort_pill(assigns) do
    ~H"""
    <button
      phx-click="sort"
      phx-value-by={@field}
      class={"font-mono text-[0.6rem] uppercase tracking-widest px-2.5 py-1 cursor-pointer transition-all duration-200 border rounded-sm " <>
        if(@active,
          do: "text-[var(--mostaza)] border-[rgba(212,160,23,0.5)] bg-[rgba(212,160,23,0.12)] shadow-[0_0_6px_rgba(212,160,23,0.1)]",
          else: "text-[var(--crema-oscura)] border-transparent hover:text-[var(--mostaza)] hover:border-[rgba(212,160,23,0.2)]"
        )}
    >
      {@label}
      <span :if={@active} class="ml-0.5">{if @dir == "asc", do: "↑", else: "↓"}</span>
    </button>
    """
  end

  # ── Helpers ───────────────────────────────────────────────

  defp sort_draws(draws, field, dir) do
    sorted = case field do
      "date" -> Enum.sort_by(draws, fn d -> d["date"] || "" end)
      "name" -> Enum.sort_by(draws, fn d -> String.downcase(d["name"] || "") end)
      "price" -> Enum.sort_by(draws, fn d -> d["ticket_price"] || 0 end)
      "tickets" -> Enum.sort_by(draws, fn d -> map_size(d["tickets"] || %{}) end)
      "prizes" -> Enum.sort_by(draws, fn d -> length(d["prizes"] || []) end)
      "status" -> Enum.sort_by(draws, fn d -> d["status"] || "" end)
      _ -> draws
    end

    if dir == "desc", do: Enum.reverse(sorted), else: sorted
  end

  defp count_unique_buyers(draw) do
    (draw["tickets"] || %{})
    |> Map.values()
    |> Enum.map(fn t -> t["client_id"] end)
    |> Enum.uniq()
    |> length()
  end
end
