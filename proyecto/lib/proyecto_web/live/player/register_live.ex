defmodule ProyectoWeb.Player.RegisterLive do
  @moduledoc """
  Registro de jugador — Las Vegas vintage, bienvenida cálida.
  """
  use ProyectoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Registro")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen flex items-center justify-center relative overflow-hidden py-12">
      <div class="lens-flare lens-flare-1" style="top: 15%; left: 5%; opacity: 0.7;"></div>
      <div class="lens-flare lens-flare-1" style="bottom: 10%; right: 5%; opacity: 0.6;"></div>

      <div class="relative z-10 w-full max-w-md mx-auto px-6">
        <.link navigate={~p"/login"} class="inline-flex items-center gap-2 mb-8 font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] hover:text-[var(--mostaza)] transition-colors">
          ← Ya tengo cuenta
        </.link>

        <div class="vintage-card halo p-8">
          <div class="text-center mb-8">
            <div class="font-mono text-[0.6rem] uppercase tracking-[0.4em] text-[var(--naranja)] mb-3">
              ◈ Nueva cuenta ◈
            </div>
            <h1 class="font-display text-3xl text-[var(--crema)] neon-gas">Únete al juego</h1>
            <div class="divider-ornament mt-4 text-[0.6rem]">◈</div>
          </div>

          <form action={~p"/session/register"} method="post" class="space-y-4">
            <input type="hidden" name="_csrf_token" value={Plug.CSRFProtection.get_csrf_token()} />
            <.glass_input name="name" label="Nombre Completo" placeholder="Juan Pérez" icon_name="hero-user" required={true} />
            <.glass_input name="document" label="Documento de Identidad" placeholder="1234567890" icon_name="hero-identification" required={true} />
            <.glass_input name="password" type="password" label="Contraseña" placeholder="Mínimo 6 caracteres" icon_name="hero-lock-closed" required={true} />
            <.glass_input name="card" label="Tarjeta (Simulada)" placeholder="4111 1111 1111 1111" icon_name="hero-credit-card" required={true} />

            <div class="pt-2">
              <.emerald_button type="submit" class="w-full justify-center">
                Conseguir mi Boleto
              </.emerald_button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
