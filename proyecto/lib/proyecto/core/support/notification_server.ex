defmodule AzarSa.Core.Support.NotificationServer do
  use GenServer

  ## 🔹 API

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def notify(client_id, message) do
    GenServer.cast(__MODULE__, {:notify, client_id, message})
  end

  def get_notifications(client_id) do
    GenServer.call(__MODULE__, {:get, client_id})
  end

  ## 🔹 Callbacks

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_cast({:notify, client_id, message}, state) do
    notifications = Map.get(state, client_id, [])

    new_notification = %{message: message, date: now()}
    new_notifications = [new_notification | notifications]

    # OPTIMIZACIÓN: Publicar en PubSub para que la web se entere AL INSTANTE
    Phoenix.PubSub.broadcast(
      Proyecto.PubSub,
      "notifications:#{client_id}",
      {:new_notification, new_notification}
    )

    {:noreply, Map.put(state, client_id, new_notifications)}
  end

  @impl true
  def handle_call({:get, client_id}, _from, state) do
    {:reply, Map.get(state, client_id, []), state}
  end

  defp now do
    DateTime.utc_now() |> DateTime.to_string()
  end
end
