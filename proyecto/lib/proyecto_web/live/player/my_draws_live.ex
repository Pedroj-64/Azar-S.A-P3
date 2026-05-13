defmodule ProyectoWeb.Player.MyDrawsLive do
  @moduledoc """
  Historial del jugador: sorteos en los que participó, compras realizadas,
  premios ganados y total gastado.
  """
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    client_id = socket.assigns.client_id
    {:ok, draws} = CentralServer.get_client_draws(client_id)
    {:ok, prizes} = CentralServer.get_client_prizes(client_id)
    {:ok, balance} = CentralServer.get_client_balance(client_id)

    # Enrich each draw with the player's specific tickets and cost
    draws_with_tickets =
      Enum.map(draws, fn draw ->
        my_tickets =
          (draw["tickets"] || %{})
          |> Enum.filter(fn {_k, t} ->
            case t do
              %{"client_id" => cid} -> cid == client_id
              _ -> false
            end
          end)
          |> Enum.map(fn {_k, t} -> t end)

        fraction_price = div(draw["ticket_price"] || 0, max(draw["fractions"] || 1, 1))
        spent_in_draw = length(my_tickets) * fraction_price

        Map.merge(draw, %{
          "my_tickets" => my_tickets,
          "spent_in_draw" => spent_in_draw
        })
      end)

    {:ok, assign(socket,
      page_title: gettext("my_draws_title"),
      draws: draws_with_tickets,
      prizes: prizes,
      balance: balance
    )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.page_header title={gettext("my_draws_title")} subtitle={gettext("my_draws_subtitle")} />

      <%!-- Balance summary --%>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <.stat_card title={gettext("stat_total_spent")} value={"$#{fmt(@balance.spent)}"} icon_name="hero-shopping-cart" color="red" />
        <.stat_card title={gettext("stat_total_won")} value={"$#{fmt(@balance.won)}"} icon_name="hero-trophy" color="yellow" />
        <.stat_card title={gettext("stat_net_balance")} value={"$#{fmt(@balance.balance)}"} icon_name="hero-scale"
          color={if @balance.balance >= 0, do: "emerald", else: "red"} />
      </div>

      <%!-- Prizes Won --%>
      <div :if={@prizes != []} class="mb-8 page-enter">
        <.glass_card>
          <h2 class="font-display text-xl text-[var(--mostaza)] mb-4">
            <.icon name="hero-trophy" class="w-6 h-6 inline mr-2" /> {gettext("prizes_won_title")}
          </h2>
          <div :for={p <- @prizes} class="flex items-center justify-between p-4 mb-2"
            style="border-radius: 2px; background: rgba(212,160,23,0.06); border: 1px solid rgba(212,160,23,0.15);">
            <div>
              <span class="text-[var(--crema)] font-semibold">{p.prize_name}</span>
              <span class="font-mono text-xs text-[var(--crema-oscura)] ml-2">({p.draw_name})</span>
              <span class="font-mono text-xs text-[var(--crema-oscura)] ml-2">— #{p.winner_number}</span>
            </div>
            <span class="font-display text-lg text-[var(--mostaza)] neon-gold">${fmt(p.amount)}</span>
          </div>
        </.glass_card>
      </div>

      <%!-- Participated Draws with purchase history --%>
      <.glass_card>
        <h2 class="font-display text-xl text-[var(--crema)] mb-4">{gettext("participated_draws_title")}</h2>
        <div :if={@draws == []}><.empty_state icon_name="hero-ticket" message={gettext("participated_draws_empty")} /></div>
        <div class="space-y-3">
          <div :for={draw <- @draws}
            class="p-4"
            style="border-radius: 2px; background: rgba(90,46,16,0.2); border: 1px solid rgba(212,160,23,0.08);">

            <div class="flex items-center justify-between mb-3">
              <div class="flex items-center gap-4">
                <div class="p-2" style="background: rgba(90,46,16,0.35); border-radius: 2px;">
                  <.icon name="hero-ticket" class="w-5 h-5 text-[var(--crema-oscura)]" />
                </div>
                <div>
                  <p class="text-[var(--crema)] font-medium">{draw["name"]}</p>
                  <p class="font-mono text-xs text-[var(--crema-oscura)]">{draw["date"]}</p>
                </div>
              </div>
              <div class="flex items-center gap-3">
                <span class="font-mono text-sm text-[var(--naranja)]">
                  {gettext("my_draws_spent_in_draw", amount: fmt(draw["spent_in_draw"]))}
                </span>
                <.status_badge status={to_string(draw["status"] || "pending")} />
              </div>
            </div>

            <%!-- Purchase detail (tickets) --%>
            <div :if={draw["my_tickets"] != []} class="ml-11 space-y-1">
              <p class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)] mb-1">
                {gettext("my_draws_tickets_count", count: length(draw["my_tickets"]))}
              </p>
              <div :for={t <- draw["my_tickets"]}
                class="flex items-center gap-3 py-1.5 px-3 font-mono text-xs"
                style="background: rgba(90,46,16,0.15); border-radius: 2px;">
                <span class="text-[var(--crema)]">#{t["number"]}</span>
                <span class="text-[var(--crema-oscura)]">
                  <%= if t["fraction"] == "full" do %>
                    {gettext("ticket_type_full")}
                  <% else %>
                    {gettext("ticket_type_fraction", frac: t["fraction"])}
                  <% end %>
                </span>
                <span class="text-[var(--crema-oscura)] ml-auto">{t["bought_at"] |> String.slice(0, 10)}</span>
              </div>
            </div>
          </div>
        </div>
      </.glass_card>
    </div>
    """
  end
end
