defmodule ProyectoWeb.Admin.LoginLive do
  @moduledoc """
  Login del administrador — estética Vegas vintage, acentos dorados.
  """
  use ProyectoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Consola Admin")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center relative overflow-hidden">
      <div class="lens-flare lens-flare-1" style="top: 5%; right: 10%; opacity: 0.9;"></div>
      <div class="lens-flare lens-flare-2" style="bottom: 10%; left: -10%; opacity: 0.5;"></div>

      <div class="relative z-10 w-full max-w-md mx-auto px-6">
        <.link navigate={~p"/"} class="inline-flex items-center gap-2 mb-8 font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] hover:text-[var(--mostaza)] transition-colors">
          ← Volver al inicio
        </.link>

        <div class="vintage-card halo p-8">
          <div class="text-center mb-8">
            <div class="font-mono text-[0.6rem] uppercase tracking-[0.4em] text-[var(--mostaza)] mb-3">
              ◈ Acceso Restringido ◈
            </div>
            <h1 class="font-display text-3xl text-[var(--crema)] neon-gold">Consola Admin</h1>
            <div class="divider-ornament mt-4 text-[0.6rem]">◈</div>
          </div>

          <form action={~p"/session/admin"} method="post" class="space-y-5">
            <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
            <.glass_input name="username" label="Usuario" placeholder="admin" icon_name="hero-user-circle" required={true} />
            <.glass_input name="password" type="password" label="Contraseña" placeholder="••••••••" icon_name="hero-lock-closed" required={true} />
            <.gold_button type="submit" class="w-full justify-center">
              Activar Sistema
            </.gold_button>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
