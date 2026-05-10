defmodule ProyectoWeb.Admin.DrawsLive do
  @moduledoc """
  Gestión de sorteos: listar, crear, agregar premios, ejecutar y eliminar.
  """
  use ProyectoWeb, :live_view

  alias AzarSa.Core.Servers.CentralServer

  @impl true
  def mount(_params, _session, socket) do
    draws = CentralServer.list_draws()

    {:ok,
     assign(socket,
       page_title: "Sorteos",
       draws: draws,
       show_create: false,
       show_prizes: nil,
       prize_draw_id: nil
     )}
  end

  @impl true
  def handle_event("toggle_create", _params, socket) do
    {:noreply, assign(socket, show_create: !socket.assigns.show_create)}
  end

  @impl true
  def handle_event("create_draw", params, socket) do
    draw_id = "draw_" <> (:crypto.strong_rand_bytes(4) |> Base.encode16(case: :lower))

    case CentralServer.create_draw(
           draw_id,
           params["name"],
           params["date"],
           String.to_integer(params["ticket_price"] || "10000"),
           String.to_integer(params["fractions"] || "1"),
           String.to_integer(params["total_tickets"] || "100")
         ) do
      {:ok, _id} ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws, show_create: false)
         |> put_flash(:info, "Sorteo creado exitosamente")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("run_draw", %{"id" => draw_id}, socket) do
    case CentralServer.run_draw(draw_id) do
      {:ok, result} ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws)
         |> put_flash(:info, "¡Sorteo ejecutado! Ganador: ##{result["winner_number"]}")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("delete_draw", %{"id" => draw_id}, socket) do
    case CentralServer.delete_draw(draw_id) do
      :ok ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws)
         |> put_flash(:info, "Sorteo eliminado")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("show_prizes", %{"id" => draw_id}, socket) do
    {:noreply, assign(socket, show_prizes: draw_id)}
  end

  @impl true
  def handle_event("hide_prizes", _params, socket) do
    {:noreply, assign(socket, show_prizes: nil)}
  end

  @impl true
  def handle_event("add_prize", %{"draw_id" => draw_id, "name" => name, "amount" => amount}, socket) do
    case CentralServer.add_prize(draw_id, name, String.to_integer(amount)) do
      {:ok, _prize} ->
        draws = CentralServer.list_draws()
        {:noreply,
         socket
         |> assign(draws: draws)
         |> put_flash(:info, "Premio agregado")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def handle_event("delete_prize", %{"draw_id" => draw_id, "prize_id" => prize_id}, socket) do
    case CentralServer.delete_prize(draw_id, prize_id) do
      :ok ->
        draws = CentralServer.list_draws()
        {:noreply, socket |> assign(draws: draws) |> put_flash(:info, "Premio eliminado")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, translate_error(reason))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex items-center justify-between mb-8">
        <.page_header title="Sorteos" subtitle="Crea, gestiona y ejecuta sorteos" />
        <.gold_button phx-click="toggle_create">
          <.icon name="hero-plus" class="w-5 h-5 mr-2 inline" />
          Nuevo Sorteo
        </.gold_button>
      </div>

      <!-- Create Form -->
      <div :if={@show_create} class="mb-8 animate-fade-in-up">
        <.glass_card>
          <h3 class="text-lg font-bold text-white mb-4">Crear Nuevo Sorteo</h3>
          <form phx-submit="create_draw" class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <.glass_input name="name" label="Nombre" placeholder="Sorteo de Navidad" required={true} />
            <.glass_input name="date" type="date" label="Fecha del Sorteo" required={true} />
            <.glass_input name="ticket_price" type="number" label="Precio del Billete ($)" placeholder="10000" required={true} />
            <.glass_input name="fractions" type="number" label="Fracciones" placeholder="1" required={true} />
            <.glass_input name="total_tickets" type="number" label="Total de Billetes" placeholder="100" required={true} />
            <div class="flex items-end">
              <.emerald_button type="submit" class="w-full">Crear Sorteo</.emerald_button>
            </div>
          </form>
        </.glass_card>
      </div>

      <!-- Draws List -->
      <div :if={@draws == []}>
        <.glass_card>
          <.empty_state icon_name="hero-ticket" message="No hay sorteos creados. ¡Crea el primero!" />
        </.glass_card>
      </div>

      <div class="space-y-4">
        <div :for={draw <- @draws}>
          <.glass_card>
            <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-4">
              <!-- Draw Info -->
              <div class="flex items-center gap-4 flex-1">
                <img src={draw_image(draw)} class="w-16 h-16 rounded-xl object-cover" />
                <div>
                  <h3 class="text-lg font-bold text-white">{draw["name"]}</h3>
                  <div class="flex items-center gap-3 mt-1">
                    <span class="text-slate-400 text-sm">
                      <.icon name="hero-calendar" class="w-4 h-4 inline mr-1" />{draw["date"] || "Sin fecha"}
                    </span>
                    <span class="text-slate-400 text-sm">
                      <.icon name="hero-banknotes" class="w-4 h-4 inline mr-1" />${format_number(draw["ticket_price"] || 0)}
                    </span>
                    <span class="text-slate-400 text-sm">
                      <.icon name="hero-squares-2x2" class="w-4 h-4 inline mr-1" />{map_size(draw["tickets"] || %{})} vendidos
                    </span>
                  </div>
                </div>
              </div>

              <!-- Actions -->
              <div class="flex items-center gap-2">
                <.status_badge status={to_string(draw["status"] || "pending")} />

                <.ghost_button
                  phx-click="show_prizes"
                  phx-value-id={draw["id"]}
                >
                  <.icon name="hero-gift" class="w-4 h-4" />
                </.ghost_button>

                <.emerald_button
                  :if={to_string(draw["status"]) == "pending"}
                  phx-click="run_draw"
                  phx-value-id={draw["id"]}
                  class="px-4 py-2 text-sm"
                  data-confirm="¿Ejecutar este sorteo?"
                >
                  <.icon name="hero-play" class="w-4 h-4 mr-1 inline" /> Ejecutar
                </.emerald_button>

                <.danger_button
                  :if={to_string(draw["status"]) == "pending"}
                  phx-click="delete_draw"
                  phx-value-id={draw["id"]}
                  data-confirm="¿Eliminar este sorteo?"
                >
                  <.icon name="hero-trash" class="w-4 h-4" />
                </.danger_button>
              </div>
            </div>

            <!-- Result (if done) -->
            <div :if={draw["result"]} class="mt-4 p-4 rounded-xl bg-emerald-500/10 border border-emerald-400/20">
              <p class="text-emerald-400 font-semibold">
                <.icon name="hero-trophy" class="w-5 h-5 inline mr-2" />
                Número ganador: #{draw["result"]["winner_number"]}
                — Premio total: ${format_number(draw["result"]["total_prize"] || 0)}
              </p>
            </div>

            <!-- Prizes Panel -->
            <div :if={@show_prizes == draw["id"]} class="mt-4 animate-fade-in-up">
              <div class="border-t border-white/10 pt-4">
                <h4 class="text-sm font-bold text-white mb-3">
                  <.icon name="hero-gift" class="w-4 h-4 inline mr-1" /> Premios ({length(draw["prizes"] || [])})
                </h4>

                <div :for={prize <- draw["prizes"] || []}
                  class="flex items-center justify-between p-3 rounded-lg bg-slate-700/30 mb-2">
                  <div>
                    <span class="text-white text-sm">{prize["name"]}</span>
                    <span class="text-yellow-400 text-sm ml-2">${format_number(prize["amount"] || 0)}</span>
                  </div>
                  <button
                    :if={to_string(draw["status"]) == "pending"}
                    phx-click="delete_prize"
                    phx-value-draw_id={draw["id"]}
                    phx-value-prize_id={prize["id"]}
                    class="text-red-400 hover:text-red-300 cursor-pointer"
                  >
                    <.icon name="hero-x-mark" class="w-4 h-4" />
                  </button>
                </div>

                <!-- Add Prize Form -->
                <form :if={to_string(draw["status"]) == "pending"}
                  phx-submit="add_prize" class="flex gap-2 mt-3">
                  <input type="hidden" name="draw_id" value={draw["id"]} />
                  <input name="name" placeholder="Nombre del premio" required
                    class="flex-1 bg-slate-700/50 border border-white/10 text-white text-sm
                           rounded-lg px-3 py-2 focus:ring-2 focus:ring-yellow-400/50 focus:outline-none" />
                  <input name="amount" type="number" placeholder="Monto" required
                    class="w-32 bg-slate-700/50 border border-white/10 text-white text-sm
                           rounded-lg px-3 py-2 focus:ring-2 focus:ring-yellow-400/50 focus:outline-none" />
                  <.gold_button type="submit" class="px-4 py-2 text-sm">Agregar</.gold_button>
                </form>
              </div>
            </div>
          </.glass_card>
        </div>
      </div>
    </div>
    """
  end

  defp draw_image(draw) do
    price = draw["ticket_price"] || 0
    cond do
      price >= 50_000 -> "/images/sorteo_oro.svg"
      price >= 20_000 -> "/images/sorteo_plata.svg"
      true -> "/images/sorteo_bronce.svg"
    end
  end

  defp format_number(n) when is_integer(n) do
    n |> Integer.to_string() |> String.reverse()
    |> String.replace(~r/(\d{3})(?=\d)/, "\\1.") |> String.reverse()
  end
  defp format_number(_), do: "0"
end
