defmodule ProyectoWeb.UIComponents do
  @moduledoc """
  Componentes UI con estética Las Vegas o Fallout New Vegas.
  Paleta: mostaza, naranja quemado, chocolate, teal.
  """
  use Phoenix.Component
  use Gettext, backend: ProyectoWeb.Gettext
  import ProyectoWeb.CoreComponents, only: [icon: 1]

  # ── Tarjeta Vintage ─────────────────────────────────────────
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def glass_card(assigns) do
    ~H"""
    <div class={["vintage-card p-6", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  # ── Botón Principal (Palanca Naranja) ──────────────────────
  attr :type, :string, default: "button"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def gold_button(assigns) do
    ~H"""
    <button type={@type} class={["btn-lever", @class]} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Botón Secundario (Palanca Teal) ────────────────────────
  attr :type, :string, default: "button"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def emerald_button(assigns) do
    ~H"""
    <button type={@type} class={["btn-lever btn-lever-teal", @class]} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Botón Fantasma ─────────────────────────────────────────
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def ghost_button(assigns) do
    ~H"""
    <button class={["btn-lever btn-lever-ghost", @class]} {@rest}>
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Botón Peligro (Rojo quemado) ───────────────────────────
  attr :type, :string, default: "button"
  attr :class, :string, default: ""
  attr :rest, :global
  slot :inner_block, required: true

  def danger_button(assigns) do
    ~H"""
    <button
      type={@type}
      class={[
        "btn-lever",
        "!bg-gradient-to-b !from-red-700 !to-red-900",
        "!shadow-[0_4px_0_#7f1d1d,0_6px_12px_rgba(0,0,0,0.4)]",
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end

  # ── Input Vintage ───────────────────────────────────────────
  attr :name, :string, required: true
  attr :type, :string, default: "text"
  attr :label, :string, default: nil
  attr :placeholder, :string, default: ""
  attr :value, :string, default: ""
  attr :icon_name, :string, default: nil
  attr :required, :boolean, default: false

  def glass_input(assigns) do
    ~H"""
    <div class="space-y-2">
      <label :if={@label} class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)]">
        {@label}
      </label>
      <div class="relative">
        <div :if={@icon_name} class="absolute left-3 top-1/2 -translate-y-1/2 text-[var(--mostaza)] opacity-60">
          <.icon name={@icon_name} class="w-4 h-4" />
        </div>
        <input
          type={@type}
          name={@name}
          value={@value}
          placeholder={@placeholder}
          required={@required}
          class={["vintage-input", @icon_name && "pl-10"]}
        />
      </div>
    </div>
    """
  end

  # ── Stat Card ───────────────────────────────────────────────
  attr :title, :string, required: true
  attr :value, :string, required: true
  attr :icon_name, :string, default: "hero-banknotes"
  attr :color, :string, default: "yellow"

  def stat_card(assigns) do
    ~H"""
    <div class="vintage-card p-5 halo">
      <p class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] mb-1">
        {@title}
      </p>
      <p class="font-display text-3xl text-[var(--mostaza)]">
        {@value}
      </p>
    </div>
    """
  end

  # ── Badge de Estado ─────────────────────────────────────────
  attr :status, :string, required: true

  def status_badge(assigns) do
    ~H"""
    <span class={[
      @status == "pending" && "badge-pending",
      @status == "done" && "badge-done"
    ]}>
      {if @status == "pending", do: gettext("status_pending"), else: gettext("status_done")}
    </span>
    """
  end

  # ── Encabezado de Página ────────────────────────────────────
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil

  def page_header(assigns) do
    ~H"""
    <div class="mb-8 border-b border-[rgba(212,160,23,0.2)] pb-4">
      <h1 class="font-display text-3xl text-[var(--crema)]">{@title}</h1>
      <p :if={@subtitle} class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)] mt-1">
        {@subtitle}
      </p>
    </div>
    """
  end

  # ── Estado Vacío ────────────────────────────────────────────
  attr :icon_name, :string, default: "hero-inbox"
  attr :message, :string, required: true

  def empty_state(assigns) do
    ~H"""
    <div class="text-center py-12">
      <div class="text-[var(--mostaza)] opacity-30 mb-4">
        <.icon name={@icon_name} class="w-12 h-12 mx-auto" />
      </div>
      <p class="font-mono text-xs uppercase tracking-widest text-[var(--crema-oscura)]">{@message}</p>
    </div>
    """
  end

  # ── Selector de Idioma ─────────────────────────────────────
  attr :locale, :string, default: "es"

  def language_selector(assigns) do
    ~H"""
    <div class="flex items-center gap-1">
      <.link
        href={"?locale=es"}
        class={[
          "px-2 py-1 font-mono text-[0.6rem] uppercase tracking-widest transition-all duration-200 border",
          if(@locale == "es",
            do: "text-[var(--mostaza)] border-[rgba(212,160,23,0.5)] bg-[rgba(212,160,23,0.12)]",
            else: "text-[var(--crema-oscura)] border-transparent hover:text-[var(--mostaza)] hover:border-[rgba(212,160,23,0.2)]"
          )
        ]}
      >
        ES
      </.link>
      <span class="text-[rgba(212,160,23,0.2)] text-[0.5rem]">│</span>
      <.link
        href={"?locale=en"}
        class={[
          "px-2 py-1 font-mono text-[0.6rem] uppercase tracking-widest transition-all duration-200 border",
          if(@locale == "en",
            do: "text-[var(--mostaza)] border-[rgba(212,160,23,0.5)] bg-[rgba(212,160,23,0.12)]",
            else: "text-[var(--crema-oscura)] border-transparent hover:text-[var(--mostaza)] hover:border-[rgba(212,160,23,0.2)]"
          )
        ]}
      >
        EN
      </.link>
    </div>
    """
  end
end
