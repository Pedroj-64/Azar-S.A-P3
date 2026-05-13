defmodule ProyectoWeb.Player.LoginLive do
  @moduledoc """
  Login del jugador — estética Vegas vintage.
  """
  use ProyectoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: gettext("player_login_title"))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center relative overflow-hidden">
      <div class="lens-flare lens-flare-1" style="top: 10%; left: -5%; opacity: 0.8;"></div>
      <div class="lens-flare lens-flare-1" style="bottom: 5%; right: -5%; opacity: 0.5;"></div>

      <div class="relative z-10 w-full max-w-md mx-auto px-6">
        <.link navigate={~p"/"} class="inline-flex items-center gap-2 mb-8 font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] hover:text-[var(--mostaza)] transition-colors">
          {gettext("player_login_back")}
        </.link>

        <div class="vintage-card halo p-8">
          <div class="text-center mb-8">
            <div class="font-mono text-[0.6rem] uppercase tracking-[0.4em] text-[var(--teal-lt)] mb-3">
              {gettext("player_login_badge")}
            </div>
            <h1 class="font-display text-3xl text-[var(--crema)] neon-teal">{gettext("player_login_title")}</h1>
            <div class="divider-ornament mt-4 text-[0.6rem]">◈</div>
          </div>

          <form action={~p"/session/player"} method="post" class="space-y-5">
            <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
            <.glass_input name="document" label={gettext("player_login_label_doc")} placeholder="1234567890" icon_name="hero-identification" required={true} />
            <.glass_input name="password" type="password" label={gettext("player_login_label_pass")} placeholder="••••••••" icon_name="hero-lock-closed" required={true} />
            <.gold_button type="submit" class="w-full justify-center">
              {gettext("player_login_submit")}
            </.gold_button>
          </form>

          <div class="divider-ornament mt-6 mb-4 text-[0.6rem]">{gettext("player_login_divider")}</div>

          <.link navigate={~p"/register"} class="block text-center font-mono text-xs uppercase tracking-widest text-[var(--naranja)] hover:neon-gas transition-all duration-300">
            {gettext("player_login_register")}
          </.link>
        </div>
      </div>
    </div>
    """
  end
end
