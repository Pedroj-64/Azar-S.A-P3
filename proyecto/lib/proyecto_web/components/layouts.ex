defmodule ProyectoWeb.Layouts do
  @moduledoc """
  Layouts de Azar S.A. — estética Las Vegas Vintage.

  Tres layouts:
  - app/1:        Portal público (landing, login, registro)
  - admin_app/1:  Consola del administrador (sidebar marrón oscuro)
  - player_app/1: Portal del jugador (sidebar chocolate)
  """
  use ProyectoWeb, :html

  embed_templates "layouts/*"

  # ── Layout Público ─────────────────────────────────────────
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="min-h-screen relative overflow-hidden">
      {render_slot(@inner_block)}
    </main>
    <.flash_group flash={@flash} />
    """
  end

  # ── Layout Admin ───────────────────────────────────────────
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def admin_app(assigns) do
    ~H"""
    <div class="min-h-screen flex">
      <%!-- Sidebar Admin --%>
      <aside class="w-60 flex flex-col fixed h-full z-10"
        style="background: linear-gradient(180deg, #2d1508 0%, #1a0d04 100%); border-right: 1px solid rgba(212,160,23,0.2);">

        <%!-- Logo --%>
        <div class="p-5" style="border-bottom: 1px solid rgba(212,160,23,0.15);">
          <.link navigate={~p"/"} class="flex items-center gap-3">
            <img src={~p"/images/logo.svg"} class="h-8" />
            <div>
              <div class="font-display text-lg text-[var(--mostaza)] neon-gold leading-none">AZAR S.A.</div>
              <div class="font-mono text-[0.55rem] uppercase tracking-widest text-[var(--naranja)] mt-0.5">
                Consola Admin
              </div>
            </div>
          </.link>
        </div>

        <%!-- Decoración ornamental --%>
        <div class="px-5 py-2 text-center" style="border-bottom: 1px solid rgba(212,160,23,0.1);">
          <span class="font-mono text-[0.5rem] tracking-[0.3em] uppercase text-[rgba(212,160,23,0.3)]">
            ◈ ─ ◈ ─ ◈
          </span>
        </div>

        <%!-- Navegación --%>
        <nav class="flex-1 px-3 py-4 space-y-1">
          <.sidebar_link href={~p"/admin"} icon="hero-chart-bar-square" label="Dashboard" />
          <.sidebar_link href={~p"/admin/draws"} icon="hero-ticket" label="Sorteos" />
          <.sidebar_link href={~p"/admin/clients"} icon="hero-users" label="Clientes" />
          <.sidebar_link href={~p"/admin/date"} icon="hero-clock" label="Fecha Sistema" />
          <.sidebar_link href={~p"/admin/reports"} icon="hero-document-chart-bar" label="Reportes" />
        </nav>

        <%!-- Idioma + Logout --%>
        <div class="px-4 py-3 flex items-center justify-between" style="border-top: 1px solid rgba(212,160,23,0.1);">
          <.language_selector locale={assigns[:locale] || "es"} />
          <.link href={~p"/session/logout"} method="delete"
            class="flex items-center gap-1.5 font-mono text-[0.65rem] uppercase tracking-widest text-red-800 hover:text-red-500 transition-colors">
            <.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" />
            <span>Salir</span>
          </.link>
        </div>
      </aside>

      <%!-- Contenido Principal --%>
      <main class="flex-1 ml-60 p-8 min-h-screen">
        {render_slot(@inner_block)}
      </main>
    </div>
    <.flash_group flash={@flash} />
    """
  end

  # ── Layout Player ──────────────────────────────────────────
  attr :flash, :map, required: true
  attr :current_scope, :map, default: nil
  slot :inner_block, required: true

  def player_app(assigns) do
    ~H"""
    <div class="min-h-screen flex">
      <%!-- Sidebar Player --%>
      <aside class="w-60 flex flex-col fixed h-full z-10"
        style="background: linear-gradient(180deg, #3d1f0d 0%, #2a1508 100%); border-right: 1px solid rgba(212,160,23,0.2);">

        <%!-- Logo --%>
        <div class="p-5" style="border-bottom: 1px solid rgba(212,160,23,0.15);">
          <.link navigate={~p"/"} class="flex items-center gap-3">
            <img src={~p"/images/logo.svg"} class="h-8" />
            <div>
              <div class="font-display text-lg text-[var(--mostaza)] neon-gold leading-none">AZAR S.A.</div>
              <div class="font-mono text-[0.55rem] uppercase tracking-widest text-[var(--teal-lt)] mt-0.5">
                Portal Jugador
              </div>
            </div>
          </.link>
        </div>

        <div class="px-5 py-2 text-center" style="border-bottom: 1px solid rgba(212,160,23,0.1);">
          <span class="font-mono text-[0.5rem] tracking-[0.3em] uppercase text-[rgba(212,160,23,0.3)]">
            ◈ ─ ◈ ─ ◈
          </span>
        </div>

        <nav class="flex-1 px-3 py-4 space-y-1">
          <.sidebar_link href={~p"/player"} icon="hero-home" label="Inicio" />
          <.sidebar_link href={~p"/player/draws"} icon="hero-ticket" label="Sorteos" />
          <.sidebar_link href={~p"/player/my-draws"} icon="hero-trophy" label="Mis Sorteos" />
          <.sidebar_link href={~p"/player/notifications"} icon="hero-bell" label="Notificaciones" />
        </nav>

        <%!-- Idioma + Logout --%>
        <div class="px-4 py-3 flex items-center justify-between" style="border-top: 1px solid rgba(212,160,23,0.1);">
          <.language_selector locale={assigns[:locale] || "es"} />
          <.link href={~p"/session/logout"} method="delete"
            class="flex items-center gap-1.5 font-mono text-[0.65rem] uppercase tracking-widest text-red-800 hover:text-red-500 transition-colors">
            <.icon name="hero-arrow-right-on-rectangle" class="w-4 h-4" />
            <span>Salir</span>
          </.link>
        </div>
      </aside>

      <main class="flex-1 ml-60 p-8 min-h-screen">
        {render_slot(@inner_block)}
      </main>
    </div>
    <.flash_group flash={@flash} />
    """
  end

  # ── Sidebar Link ──────────────────────────────────────────
  attr :href, :string, required: true
  attr :icon, :string, required: true
  attr :label, :string, required: true

  defp sidebar_link(assigns) do
    ~H"""
    <.link navigate={@href} class="sidebar-link">
      <.icon name={@icon} class="w-4 h-4 opacity-70" />
      <span>{@label}</span>
    </.link>
    """
  end

  # ── Flash Group ────────────────────────────────────────────
  attr :flash, :map, required: true
  attr :id, :string, default: "flash-group"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />
      <.flash
        id="client-error" kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
      <.flash
        id="server-error" kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end
end
