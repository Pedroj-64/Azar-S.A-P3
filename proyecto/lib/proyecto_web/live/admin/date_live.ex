defmodule ProyectoWeb.Admin.DateLive do
  use ProyectoWeb, :live_view
  alias AzarSa.Core.Support.SystemDate

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    now = DateTime.utc_now()

    {:ok, assign(socket,
      page_title: gettext("date_title"),
      current_date: SystemDate.get_date(),
      clock_hours: now.hour,
      clock_minutes: now.minute,
      clock_seconds: now.second,
      executed_draws: nil
    )}
  end

  @impl true
  def handle_info(:tick, socket) do
    now = DateTime.utc_now()
    {:noreply, assign(socket,
      clock_hours: now.hour,
      clock_minutes: now.minute,
      clock_seconds: now.second
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
    # Calculate angles for clock hands
    hour_angle = rem(assigns.clock_hours, 12) * 30 + assigns.clock_minutes * 0.5
    minute_angle = assigns.clock_minutes * 6 + assigns.clock_seconds * 0.1
    second_angle = assigns.clock_seconds * 6

    assigns = assign(assigns,
      hour_angle: hour_angle,
      minute_angle: minute_angle,
      second_angle: second_angle
    )

    ~H"""
    <div>
      <.page_header title={gettext("date_title")} subtitle={gettext("date_subtitle")} />
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

        <%!-- Clock Card --%>
        <.glass_card>
          <div class="text-center">
            <%!-- SVG Analog Clock --%>
            <div class="mx-auto mb-6" style="width: 200px; height: 200px;">
              <svg viewBox="0 0 200 200" class="w-full h-full" style="filter: drop-shadow(0 0 8px rgba(212,160,23,0.15));">
                <%!-- Clock face --%>
                <circle cx="100" cy="100" r="95" fill="none" stroke="rgba(212,160,23,0.3)" stroke-width="2" />
                <circle cx="100" cy="100" r="90" fill="rgba(61,31,13,0.8)" stroke="rgba(212,160,23,0.15)" stroke-width="1" />

                <%!-- Hour markers --%>
                <%= for i <- 0..11 do %>
                  <line
                    x1="100" y1="15"
                    x2="100" y2={if rem(i, 3) == 0, do: "25", else: "20"}
                    stroke={if rem(i, 3) == 0, do: "rgba(212,160,23,0.8)", else: "rgba(200,180,138,0.4)"}
                    stroke-width={if rem(i, 3) == 0, do: "2.5", else: "1"}
                    transform={"rotate(#{i * 30} 100 100)"}
                  />
                <% end %>

                <%!-- Minute ticks --%>
                <%= for i <- 0..59 do %>
                  <line
                    :if={rem(i, 5) != 0}
                    x1="100" y1="13"
                    x2="100" y2="16"
                    stroke="rgba(200,180,138,0.2)"
                    stroke-width="0.5"
                    transform={"rotate(#{i * 6} 100 100)"}
                  />
                <% end %>

                <%!-- Hour numbers --%>
                <%= for i <- 1..12 do %>
                  <text
                    x={100 + 72 * :math.sin(i * :math.pi / 6)}
                    y={100 - 72 * :math.cos(i * :math.pi / 6) + 5}
                    text-anchor="middle"
                    fill="rgba(212,160,23,0.7)"
                    font-family="'DM Mono', monospace"
                    font-size="12"
                    font-weight="500"
                  >{i}</text>
                <% end %>

                <%!-- Hour hand --%>
                <line
                  x1="100" y1="100" x2="100" y2="42"
                  stroke="var(--crema)" stroke-width="3.5" stroke-linecap="round"
                  transform={"rotate(#{@hour_angle} 100 100)"}
                  style="transition: transform 0.5s ease;"
                />

                <%!-- Minute hand --%>
                <line
                  x1="100" y1="100" x2="100" y2="28"
                  stroke="var(--crema-oscura)" stroke-width="2" stroke-linecap="round"
                  transform={"rotate(#{@minute_angle} 100 100)"}
                  style="transition: transform 0.3s ease;"
                />

                <%!-- Second hand --%>
                <line
                  x1="100" y1="115" x2="100" y2="22"
                  stroke="var(--naranja)" stroke-width="1" stroke-linecap="round"
                  transform={"rotate(#{@second_angle} 100 100)"}
                />

                <%!-- Center dot --%>
                <circle cx="100" cy="100" r="4" fill="var(--mostaza)" />
                <circle cx="100" cy="100" r="2" fill="var(--chocolate)" />

                <%!-- Brand text --%>
                <text x="100" y="140" text-anchor="middle" fill="rgba(212,160,23,0.4)"
                  font-family="'DM Mono', monospace" font-size="6" letter-spacing="0.15em">AZAR S.A.</text>
              </svg>
            </div>

            <%!-- Digital time --%>
            <p class="font-mono text-lg text-[var(--crema)] mb-1">
              {String.pad_leading(to_string(@clock_hours), 2, "0")}:<span class="neon-teal">{String.pad_leading(to_string(@clock_minutes), 2, "0")}</span>:<span class="text-[var(--naranja)]">{String.pad_leading(to_string(@clock_seconds), 2, "0")}</span>
            </p>

            <p class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] mb-2">{gettext("date_current_label")}</p>
            <p class="font-display text-4xl text-[var(--crema)] neon-gold mb-2">{@current_date}</p>
          </div>
        </.glass_card>

        <%!-- Advance Date Card --%>
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

      <%!-- Executed Draws --%>
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
