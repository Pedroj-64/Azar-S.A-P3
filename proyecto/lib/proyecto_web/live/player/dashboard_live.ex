defmodule ProyectoWeb.Player.DashboardLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer
  alias AzarSa.Core.Data.Store

  @recharge_presets [50_000, 100_000, 200_000, 500_000]

  @impl true
  def mount(_params, _session, socket) do
    client_id = socket.assigns.client_id
    {:ok, balance} = CentralServer.get_client_balance(client_id)
    draws = CentralServer.list_draws()
    pending = Enum.filter(draws, &(&1["status"] == "pending")) |> Enum.take(3)

    # Get masked credit card
    clients = Store.read("clients.json")
    client = Enum.find(clients, fn c -> c["id"] == client_id end)
    card = client["credit_card"] || ""
    masked_card = mask_card(card)

    {:ok, assign(socket,
      page_title: gettext("nav_home"),
      balance: balance,
      pending_draws: pending,
      masked_card: masked_card,
      show_recharge: false,
      recharge_amount: nil,
      recharge_presets: @recharge_presets
    )}
  end

  # ── Recharge Events ──

  @impl true
  def handle_event("toggle_recharge", _params, socket) do
    {:noreply, assign(socket, show_recharge: !socket.assigns.show_recharge, recharge_amount: nil)}
  end

  @impl true
  def handle_event("select_preset", %{"amount" => amount_str}, socket) do
    {:noreply, assign(socket, recharge_amount: String.to_integer(amount_str))}
  end

  @impl true
  def handle_event("recharge", %{"amount" => amount_str}, socket) do
    amount = String.to_integer(amount_str)

    if amount <= 0 or amount > 10_000_000 do
      {:noreply, put_flash(socket, :error, "El monto debe ser entre $1 y $10.000.000")}
    else
      case CentralServer.credit_client_balance(socket.assigns.client_id, amount) do
        {:ok, _new_balance} ->
          {:ok, balance} = CentralServer.get_client_balance(socket.assigns.client_id)

          {:noreply,
           socket
           |> assign(balance: balance, show_recharge: false, recharge_amount: nil)
           |> put_flash(:info, "¡Recarga exitosa! Se añadieron $#{fmt(amount)} a tu billetera")}

        {:error, _reason} ->
          {:noreply, put_flash(socket, :error, "Error al procesar la recarga")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header
        title={gettext("player_dashboard_greeting", name: @client_name || gettext("player_dashboard_default_name"))}
        subtitle={gettext("player_dashboard_subtitle")}
      />

      <div class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
        <%!-- Wallet Card with Recharge Button --%>
        <div class="vintage-card p-5 halo relative">
          <p class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] mb-1">
            Billetera
          </p>
          <p class="font-display text-3xl text-[var(--mostaza)]">
            $<%= fmt(@balance.wallet) %>
          </p>
          <button phx-click="toggle_recharge"
            class="mt-3 w-full flex items-center justify-center gap-2 px-3 py-2 font-mono text-[0.65rem] uppercase tracking-widest cursor-pointer transition-all duration-200 border rounded-sm text-[var(--teal-lt)] border-[rgba(42,107,107,0.4)] bg-[rgba(42,107,107,0.12)] hover:bg-[rgba(42,107,107,0.25)]">
            <.icon name="hero-plus-circle" class="w-4 h-4" /> Recargar
          </button>
        </div>

        <.stat_card title={gettext("stat_total_spent")} value={"$#{fmt(@balance.spent)}"} icon_name="hero-shopping-cart" color="red" />
        <.stat_card title={gettext("stat_total_won")} value={"$#{fmt(@balance.won)}"} icon_name="hero-trophy" color="yellow" />
        <.stat_card title={gettext("stat_net_balance")} value={"$#{fmt(@balance.balance)}"} icon_name="hero-scale"
          color={if @balance.balance >= 0, do: "emerald", else: "red"} />
      </div>

      <%!-- Recharge Panel --%>
      <div :if={@show_recharge} class="mb-8 page-enter">
        <.glass_card>
          <div class="flex items-center justify-between mb-4">
            <h3 class="font-display text-lg text-[var(--crema)]">
              <.icon name="hero-credit-card" class="w-5 h-5 inline mr-2" /> Recargar Billetera
            </h3>
            <button phx-click="toggle_recharge" class="text-[var(--crema-oscura)] hover:text-[var(--mostaza)] cursor-pointer transition-colors">
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </button>
          </div>

          <%!-- Card Info --%>
          <div class="flex items-center gap-3 mb-5 p-3"
            style="border-radius: 2px; background: rgba(90,46,16,0.25); border: 1px solid rgba(212,160,23,0.1);">
            <div class="p-2 bg-[rgba(212,160,23,0.1)]" style="border-radius: 2px;">
              <.icon name="hero-credit-card" class="w-6 h-6 text-[var(--mostaza)]" />
            </div>
            <div>
              <p class="font-mono text-sm text-[var(--crema)]"><%= @masked_card %></p>
              <p class="font-mono text-[0.55rem] uppercase tracking-widest text-[var(--crema-oscura)]">Tarjeta asociada</p>
            </div>
          </div>

          <%!-- Quick Amounts --%>
          <p class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)] mb-3">Monto rápido</p>
          <div class="grid grid-cols-2 md:grid-cols-4 gap-3 mb-5">
            <button :for={preset <- @recharge_presets}
              phx-click="select_preset"
              phx-value-amount={to_string(preset)}
              class={"flex items-center justify-center py-3 px-4 font-mono text-sm cursor-pointer transition-all duration-200 border rounded-sm " <>
                if(@recharge_amount == preset,
                  do: "text-[var(--mostaza)] border-[rgba(212,160,23,0.5)] bg-[rgba(212,160,23,0.15)] shadow-[0_0_8px_rgba(212,160,23,0.1)]",
                  else: "text-[var(--crema-oscura)] border-[rgba(212,160,23,0.12)] bg-[rgba(90,46,16,0.2)] hover:text-[var(--mostaza)] hover:border-[rgba(212,160,23,0.3)]"
                )}>
              $<%= fmt(preset) %>
            </button>
          </div>

          <%!-- Custom Amount + Submit --%>
          <form phx-submit="recharge" class="flex flex-col md:flex-row gap-3">
            <div class="flex-1">
              <label class="font-mono text-[0.55rem] uppercase tracking-widest text-[var(--crema-oscura)] block mb-1">
                Monto personalizado
              </label>
              <input name="amount" type="number" min="1000" max="10000000" step="1000"
                value={@recharge_amount}
                placeholder="Ingresa el monto"
                required
                class="vintage-input w-full" />
            </div>
            <div class="flex items-end">
              <.emerald_button type="submit" class="w-full md:w-auto px-8 py-3">
                <.icon name="hero-bolt" class="w-4 h-4 mr-2 inline" /> Recargar
              </.emerald_button>
            </div>
          </form>

          <p class="font-mono text-[0.5rem] text-[var(--crema-oscura)] mt-3 italic">
            * Recarga simulada. El cargo se aplica a la tarjeta asociada.
          </p>
        </.glass_card>
      </div>

      <.glass_card>
        <div class="flex items-center justify-between mb-6">
          <h2 class="font-display text-xl text-[var(--crema)]">{gettext("player_available_draws")}</h2>
          <.link navigate={~p"/player/draws"} class="font-mono text-xs uppercase tracking-widest text-[var(--teal-lt)] hover:neon-teal transition-all">{gettext("player_see_all")}</.link>
        </div>
        <div :if={@pending_draws == []}><.empty_state icon_name="hero-ticket" message={gettext("player_no_draws")} /></div>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <.link :for={draw <- @pending_draws} navigate={~p"/player/draws/#{draw["id"]}"}
            class="group p-4 vintage-card hover:halo transition-all duration-300">
            <img src={draw_img(draw)} class="w-full h-24 object-cover mb-3 opacity-70 group-hover:opacity-100 transition" style="border-radius: 2px;" />
            <h3 class="text-[var(--crema)] font-semibold group-hover:text-[var(--mostaza)] transition-colors">{draw["name"]}</h3>
            <p class="font-mono text-xs text-[var(--crema-oscura)] mt-1">{draw["date"]} — ${fmt(draw["ticket_price"] || 0)}</p>
          </.link>
        </div>
      </.glass_card>
    </div>
    """
  end

  # ── Helpers ──

  defp mask_card(card) when byte_size(card) >= 4 do
    last4 = String.slice(card, -4, 4)
    "•••• •••• •••• #{last4}"
  end
  defp mask_card(_), do: "•••• •••• •••• ••••"
end
