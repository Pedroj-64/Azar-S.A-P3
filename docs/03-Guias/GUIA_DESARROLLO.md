# Guía de Desarrollo - Azar S.A

## 🚀 Configuración Inicial

### 1. Clonar/Descargar Proyecto

```bash
cd /home/ajolote/Documentos/Codigo
# Proyecto ya en: Azar S.A/
```

### 2. Estructura de Carpetas

```
Azar S.A/
├── server/           # Servidor central con Phoenix
├── admin_client/     # Cliente administrador
├── player_client/    # Cliente jugador
├── shared_code/      # Módulos compartidos
├── docs/             # Documentación
└── scripts/          # Scripts útiles
```

---

## 📦 Instalación de Dependencias

### Por Aplicación

```bash
# Servidor Central
cd server
mix deps.get
mix compile

# Admin Client
cd admin_client
mix deps.get
mix compile

# Player Client
cd player_client
mix deps.get
mix compile
```

### Archivos `mix.exs`

Cada aplicación necesita un `mix.exs` con:

```elixir
defp deps do
  [
    {:phoenix, "~> 1.7"},
    {:phoenix_live_view, "~> 0.20"},
    {:phoenix_html, "~> 3.3"},
    {:phoenix_html_helpers, "~> 1.0"},
    {:plug_cowboy, "~> 2.6"},
    {:jason, "~> 1.4"},
    {:gettext, "~> 0.20"},
    {:bcrypt_elixir, "~> 3.0"},
  ]
end
```

---

## 🏗️ Estructura de Contextos

### Servidor (`server/lib/azar_server/contexts/`)

```
contexts/
├── sorteos/              # Contexto de Sorteos
│   ├── sorteo.ex        # Schema/Struct
│   ├── schemas/
│   │   ├── billete.ex
│   │   └── premio.ex
│   └── operations.ex    # Funciones de negocio
│
├── auditoria/            # Contexto de Auditoría
│   ├── registro.ex
│   └── operations.ex
│
└── notificaciones/       # Contexto de Notificaciones
    ├── notificacion.ex
    └── broadcaster.ex
```

### Ejemplo: `contexts/sorteos/operations.ex`

```elixir
defmodule AzarServer.Contexts.Sorteos.Operations do
  @moduledoc "Operaciones de negocio para sorteos"
  
  alias AzarServer.Contexts.Sorteos

  def crear_sorteo(attrs) do
    # Validar atributos
    # Crear archivo JSON
    # Iniciar servidor de sorteo
    {:ok, sorteo}
  end

  def obtener_sorteo(id) do
    # Leer del JSON
    {:ok, sorteo}
  end

  def listar_sorteos() do
    # Leer todos de JSON
    {:ok, sorteos}
  end

  def ejecutar_sorteo(id) do
    # Generar números ganadores
    # Calcular ganadores
    # Notificar jugadores
    {:ok, resultado}
  end
end
```

---

## 🌐 Controllers y Routes

### Estructura

```
lib/azar_server/
├── channels/
│   ├── sorteo_channel.ex      # WebSocket para sorteos
│   └── notificacion_channel.ex
│
└── controllers/
    ├── api_controller.ex       # API REST
    ├── sorteo_controller.ex
    └── health_controller.ex
```

### Ejemplo: Routes (`config/routes.ex`)

```elixir
scope "/api", AzarServer do
  pipe_through :api
  
  # Sorteos
  get "/sorteos", SorteoController, :index
  post "/sorteos", SorteoController, :create
  get "/sorteos/:id", SorteoController, :show
  delete "/sorteos/:id", SorteoController, :delete
  post "/sorteos/:id/ejecutar", SorteoController, :ejecutar
  
  # Compras
  post "/compras", CompraController, :create
  delete "/compras/:id", CompraController, :devolver
  
  # Health
  get "/health", HealthController, :check
end
```

---

## 📡 WebSockets con Channels

### Crear Channel

```elixir
# lib/azar_server/channels/sorteo_channel.ex
defmodule AzarServerWeb.SorteoChannel do
  use AzarServerWeb, :channel
  
  def join("sorteo:" <> sorteo_id, _payload, socket) do
    if authorized?(socket, sorteo_id) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end
  
  def handle_in("comprar", payload, socket) do
    # Procesar compra
    broadcast(socket, "update", %{"evento" => "billete_comprado"})
    {:noreply, socket}
  end
  
  defp authorized?(socket, sorteo_id) do
    # Validar autorización
    true
  end
end
```

### Client-side (JavaScript)

```javascript
let channel = socket.channel("sorteo:123", {})

channel.join()
  .receive("ok", resp => console.log("Conectado", resp))
  .receive("error", resp => console.log("Error", resp))

channel.on("update", payload => {
  console.log("Actualización:", payload)
})

// Enviar mensaje
channel.push("comprar", {
  billete: 42,
  cantidad: 5000
})
```

---

## 💾 Manejo de Datos con JSON

### Lectura/Escritura

```elixir
defmodule AzarServer.Storage do
  @data_dir "priv/data/"
  
  def read_sorteos() do
    path = Path.join(@data_dir, "sorteos.json")
    case File.read(path) do
      {:ok, content} -> Jason.decode!(content)
      {:error, _} -> %{"sorteos" => []}
    end
  end
  
  def write_sorteos(data) do
    path = Path.join(@data_dir, "sorteos.json")
    File.write(path, Jason.encode!(data, pretty: true))
  end
  
  def append_log(mensaje) do
    path = Path.join([@data_dir, "..", "logs"], "auditoria.log")
    File.write(path, "#{timestamp()}: #{mensaje}\n", [:append])
  end
  
  defp timestamp() do
    DateTime.utc_now() |> DateTime.to_iso8601()
  end
end
```

---

## 🔄 Procesos OTP

### Supervisor de Sorteos

```elixir
# lib/azar_server/supervisors/sorteo_supervisor.ex
defmodule AzarServer.SorteoSupervisor do
  use DynamicSupervisor
  
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end
  
  def start_sorteo(sorteo_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {AzarServer.SorteoServer, sorteo_id}
    )
  end
  
  @impl true
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
```

### GenServer de Sorteo

```elixir
# lib/azar_server/sorters/sorteo_server.ex
defmodule AzarServer.SorteoServer do
  use GenServer
  
  def start_link(sorteo_id) do
    GenServer.start_link(__MODULE__, sorteo_id, name: via_tuple(sorteo_id))
  end
  
  def comprar_billete(sorteo_id, numero, usuario) do
    GenServer.call(via_tuple(sorteo_id), {:comprar, numero, usuario})
  end
  
  @impl true
  def init(sorteo_id) do
    {:ok, sorteo} = Storage.get_sorteo(sorteo_id)
    {:ok, %{id: sorteo_id, estado: sorteo}}
  end
  
  @impl true
  def handle_call({:comprar, numero, usuario}, _from, state) do
    # Validar disponibilidad
    # Descontar billete
    # Guardar
    {:reply, {:ok, billete}, state}
  end
  
  defp via_tuple(sorteo_id) do
    {:via, Registry, {AzarServer.SorteoRegistry, sorteo_id}}
  end
end
```

---

## 🧪 Testing

### Estructura de Tests

```
test/
├── contexts/
│   ├── sorteos_test.exs
│   └── compras_test.exs
├── channels/
│   └── sorteo_channel_test.exs
└── controllers/
    └── sorteo_controller_test.exs
```

### Ejemplo de Test

```elixir
defmodule AzarServer.Contexts.SorteosTest do
  use ExUnit.Case
  
  alias AzarServer.Contexts.Sorteos.Operations
  
  test "crear_sorteo/1 crea un sorteo válido" do
    attrs = %{
      nombre: "Lotería Marzo",
      fecha: "2026-03-15",
      valor_billete: 5000,
      fracciones: 10,
      billetes: 1000
    }
    
    assert {:ok, sorteo} = Operations.crear_sorteo(attrs)
    assert sorteo.nombre == "Lotería Marzo"
    assert sorteo.estado == :abierto
  end
end
```

---

## 🛠️ Debugging

### Logger

```elixir
require Logger

def proceso_importante() do
  Logger.debug("Iniciando proceso")
  Logger.info("Proceso en curso")
  Logger.warn("Advertencia: tiempo lento")
  Logger.error("Error crítico")
end
```

### IEx (Interactive Elixir)

```bash
# Iniciar servidor en modo interactivo
iex -S mix phx.server

# En la consola:
iex(1)> alias AzarServer.Contexts.Sorteos.Operations
iex(2)> Operations.listar_sorteos()
iex(3)> Operations.obtener_sorteo(1)
```

---

## 📋 Checklist de Desarrollo

- [ ] Crear contexto de dominio
- [ ] Implementar lógica de negocio
- [ ] Crear schema/struct
- [ ] Implementar operations (funciones públicas)
- [ ] Crear controller
- [ ] Definir routes
- [ ] Crear channel (si es necesario)
- [ ] Escribir tests
- [ ] Documentar funciones
- [ ] Refactorizar código

---

## 🔍 Comandos Útiles

```bash
# Compilar
mix compile

# Tests
mix test
mix test --watch

# Formato
mix format

# Linter
mix credo

# IEx interactivo
iex -S mix

# Servidor Phoenix
mix phx.server

# Generar documentación
mix docs
```

---

## 📚 Recursos

- [Elixir Docs](https://elixir-lang.org/)
- [Phoenix Docs](https://hexdocs.pm/phoenix/)
- [OTP Docs](https://erlang.org/doc/)

---

**Versión**: 1.0  
**Última actualización**: Abril 2026
