defmodule ProyectoWeb.Admin.LoginLive do
  @moduledoc """
  Login del administrador — estética Vegas vintage, acentos dorados.
  """
  use ProyectoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: gettext("admin_login_title"), login_error: nil)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    error = Phoenix.Flash.get(socket.assigns.flash, :error)
    {:noreply, assign(socket, login_error: error)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center relative overflow-hidden">
      <div class="lens-flare lens-flare-1" style="top: 5%; right: 10%; opacity: 0.9;"></div>
      <div class="lens-flare lens-flare-2" style="bottom: 10%; left: -10%; opacity: 0.5;"></div>

      <div class="relative z-10 w-full max-w-md mx-auto px-6">
        <.link navigate={~p"/"} class="inline-flex items-center gap-2 mb-8 font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] hover:text-[var(--mostaza)] transition-colors">
          {gettext("admin_login_back")}
        </.link>

        <div class="vintage-card halo p-8">
          <div class="text-center mb-8">
            <div class="font-mono text-[0.6rem] uppercase tracking-[0.4em] text-[var(--mostaza)] mb-3">
              {gettext("admin_login_badge")}
            </div>
            <h1 class="font-display text-3xl text-[var(--crema)] neon-gold">{gettext("admin_login_title")}</h1>
            <div class="divider-ornament mt-4 text-[0.6rem]">◈</div>
          </div>

          <%!-- Error Message --%>
          <div :if={@login_error} class="mb-5 p-3 page-enter" style="border-radius: 2px; background: rgba(194,82,26,0.15); border: 1px solid rgba(194,82,26,0.3);">
            <div class="flex items-center gap-2">
              <.icon name="hero-exclamation-triangle" class="w-5 h-5 text-[var(--naranja)] shrink-0" />
              <p class="font-mono text-sm text-[var(--naranja)]">{@login_error}</p>
            </div>
          </div>

          <form action={~p"/session/admin"} method="post" class="space-y-5">
            <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
            <.glass_input name="username" label={gettext("admin_login_label_user")} placeholder="admin" icon_name="hero-user-circle" required={true} />
            <.glass_input name="password" type="password" label={gettext("admin_login_label_pass")} placeholder="••••••••" icon_name="hero-lock-closed" required={true} />
            <.gold_button type="submit" class="w-full justify-center">
              {gettext("admin_login_submit")}
            </.gold_button>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
