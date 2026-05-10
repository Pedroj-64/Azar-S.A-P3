defmodule ProyectoWeb.PageLive.Home do
  @moduledoc """
  Portal de entrada — Las Vegas Vintage.
  Hero dividido: fondo alfombra + tarjeta de acceso con efectos de neón de gas.
  """
  use ProyectoWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Bienvenido")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="min-h-screen relative flex items-center justify-center overflow-hidden">

      <%!-- ── LENS FLARES ────────────────────────────────────── --%>
      <div class="lens-flare lens-flare-1" style="top: -80px; left: -80px;"></div>
      <div class="lens-flare lens-flare-2" style="top: 200px; right: -100px;"></div>
      <div class="lens-flare lens-flare-1" style="bottom: -60px; left: 40%; opacity: 0.6;"></div>

      <%!-- ── FONDO HERO SVG ──────────────────────────────────── --%>
      <div class="absolute inset-0 overflow-hidden pointer-events-none">
        <img src={~p"/images/hero_login.svg"} class="w-full h-full object-cover opacity-20" />
        <div class="absolute inset-0" style="background: linear-gradient(135deg, rgba(61,31,13,0.85) 0%, rgba(42,21,8,0.7) 50%, rgba(26,13,4,0.9) 100%);"></div>
      </div>

      <%!-- ── CONTENIDO PRINCIPAL ────────────────────────────── --%>
      <div class="relative z-10 max-w-5xl w-full mx-auto px-6 py-12 flex flex-col lg:flex-row items-center gap-16">

        <%!-- Lado izquierdo: marca --%>
        <div class="flex-1 text-center lg:text-left">
          <%!-- Badge ornamental --%>
          <div class="vintage-badge mb-6 inline-flex">
            <span>◈</span>
            <span>Sistema de Lotería · Est. 2024</span>
            <span>◈</span>
          </div>

          <%!-- Logo --%>
          <img src={~p"/images/logo.svg"} class="h-20 mb-6 mx-auto lg:mx-0" />

          <%!-- Título con neón --%>
          <h1 class="font-display text-6xl lg:text-7xl leading-none mb-4">
            <span class="neon-gold text-[var(--mostaza)]">Tu</span>
            <span class="text-[var(--crema)]"> suerte</span>
            <br />
            <span class="neon-gas text-[var(--naranja)]">comienza</span>
            <br />
            <span class="text-[var(--crema)]">aquí</span>
          </h1>

          <%!-- Divisor ornamental --%>
          <div class="divider-ornament my-6 max-w-xs mx-auto lg:mx-0">◈</div>

          <p class="font-body text-[var(--crema-oscura)] text-base leading-relaxed max-w-sm mx-auto lg:mx-0">
            Participa en sorteos exclusivos. Compra tu billete,
            espera el número ganador y vive la emoción del azar.
          </p>
        </div>

        <%!-- Lado derecho: tarjeta de acceso --%>
        <div class="w-full max-w-sm">
          <div class="vintage-card halo p-8">

            <%!-- Cabecera ornamental --%>
            <div class="text-center mb-8">
              <div class="font-mono text-[0.6rem] uppercase tracking-[0.4em] text-[var(--mostaza)] mb-2">
                ◈ Acceso al Sistema ◈
              </div>
              <h2 class="font-display text-2xl text-[var(--crema)]">Selecciona tu rol</h2>
            </div>

            <%!-- Opción Jugador --%>
            <.link navigate={~p"/login"}
              class="group flex items-center gap-4 p-4 mb-3 transition-all duration-200"
              style="border: 1px solid rgba(42,107,107,0.3); border-radius: 2px; background: rgba(42,107,107,0.08);">
              <div class="text-[var(--teal-lt)] group-hover:neon-teal transition-all">
                <.icon name="hero-user" class="w-6 h-6" />
              </div>
              <div class="flex-1">
                <div class="font-display text-[var(--crema)] text-base">Jugador</div>
                <div class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)]">
                  Comprar billetes y ganar
                </div>
              </div>
              <div class="text-[var(--teal-lt)] opacity-0 group-hover:opacity-100 transition-opacity">→</div>
            </.link>

            <%!-- Opción Admin --%>
            <.link navigate={~p"/admin/login"}
              class="group flex items-center gap-4 p-4 mb-6 transition-all duration-200"
              style="border: 1px solid rgba(212,160,23,0.3); border-radius: 2px; background: rgba(212,160,23,0.06);">
              <div class="text-[var(--mostaza)] group-hover:neon-gold transition-all">
                <.icon name="hero-shield-check" class="w-6 h-6" />
              </div>
              <div class="flex-1">
                <div class="font-display text-[var(--crema)] text-base">Administrador</div>
                <div class="font-mono text-[0.6rem] uppercase tracking-widest text-[var(--crema-oscura)]">
                  Gestión del sistema
                </div>
              </div>
              <div class="text-[var(--mostaza)] opacity-0 group-hover:opacity-100 transition-opacity">→</div>
            </.link>

            <%!-- Divisor ornamental --%>
            <div class="divider-ornament text-[0.6rem] mb-5">o bien</div>

            <%!-- Registro --%>
            <.link navigate={~p"/register"}
              class="block text-center font-mono text-xs uppercase tracking-widest text-[var(--naranja)] hover:neon-gas transition-all duration-300">
              ¿Primera vez? Regístrate aquí →
            </.link>

          </div>

          <%!-- Etiqueta inferior --%>
          <div class="text-center mt-4">
            <span class="font-mono text-[0.55rem] uppercase tracking-[0.3em] text-[rgba(212,160,23,0.3)]">
              © Azar S.A. · Todos los derechos reservados
            </span>
          </div>
        </div>

      </div>
    </div>
    """
  end
end
