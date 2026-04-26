# Plan de Trabajo - Arquitectura Azar S.A P3

Documento que lista todos los pasos necesarios para completar y corregir la arquitectura del proyecto.

---

## 📊 ESTADO ACTUAL DEL PROYECTO

### Componentes y su estatus

| Componente | Estado | Tipo | Compilable | Funcional |
|-----------|--------|------|:----------:|:---------:|
| **Server** | Implementado | App Phoenix completa | ✅ Sí | ✅ Sí |
| **Admin Client** | Parcial | Código Elixir suelto | ❌ No | ⚠️ Parcial |
| **Player Client** | Parcial | Código Elixir suelto | ❌ No | ⚠️ Parcial |
| **Shared Code** | Implementado | Módulos Elixir | ❌ No | ⚠️ Imports rotos |

---

## 🔴 PROBLEMAS CRÍTICOS (Bloquean compilación)

### 1. Imports incorrectos en Shared Code

**Problema:**
Todos los `operations.ex` en admin_client, player_client y server importan así:

```elixir
alias AzarShared.Validations
alias AzarShared.Calculations
alias AzarShared.JsonHelper
alias AzarShared.CryptoHelper
alias AzarShared.DateHelpers
alias AzarShared.RandomHelper
```

Pero los módulos reales están en:
```elixir
AzarShared.Utils.Validations
AzarShared.Utils.Calculations
AzarShared.Utils.JsonHelper
AzarShared.Utils.CryptoHelper
AzarShared.Utils.DateHelpers
AzarShared.Utils.RandomHelper
```

**Impacto:** UndefinedFunctionError en tiempo de ejecución/compilación.

**Archivos afectados:**
- `admin_client/lib/azar_admin/contexts/*/operations.ex` (3 archivos)
- `player_client/lib/azar_player/contexts/*/operations.ex` (2 archivos)
- `server/lib/azar_server/contexts/*/operations.ex` (3 archivos)

### 2. Admin Client y Player Client no son aplicaciones compilables

**Problema:**
Ambas carpetas contienen código Elixir bien estructurado pero:
- ❌ No tienen `mix.exs`
- ❌ No tienen `lib/azar_admin/application.ex` (supervisor)
- ❌ No tienen `router.ex` ni `endpoint.ex`
- ❌ No son proyectos Mix válidos

**Impacto:** No pueden compilarse ni ejecutarse independientemente.

**Decisión requerida:** ¿Cómo deben ser?
- **Opción A:** Aplicaciones Phoenix independientes (cada una con su mix.exs y estructura completa)
- **Opción B:** Librerías dentro del server (carpetas internas como `lib/azar_server/admin/`)
- **Opción C:** Aplicaciones OTP externas que se comunican con server vía HTTP

### 3. Inconsistencia en persistencia de datos

**Problema:**
Cada componente escribe a su propio `priv/data/`:

```
Server:       /server/priv/data/draws.json
Admin:        /admin_client/priv/data/draws.json
Player:       /player_client/priv/data/usuarios.json
```

**Impacto:** NO HAY SINCRONIZACIÓN. Cada componente tiene copia local → datos inconsistentes.

---

## 🟡 PROBLEMAS IMPORTANTES

### 4. WebSocket Channels no implementados

**Problema:**
- Carpeta `server/lib/azar_server/channels/` existe pero está **vacía**
- Documentación menciona channels pero no hay implementación
- No hay comunicación real-time

**Afectados:**
- Notificaciones de sorteos
- Actualizaciones de estado en tiempo real
- Broadcast de eventos

### 5. Autenticación descentralizada

**Problema:**
- Cada componente valida credenciales por su lado
- No hay tokens JWT compartidos
- No hay sesiones centralizadas
- No hay middleware de autenticación

**Contextos duplicados:**
- `admin_client/contexts/users/` valida admins
- `player_client/contexts/users/` valida jugadores
- `server/contexts/` no tiene validación centralizada

### 6. Sin mecanismo de sincronización de datos

**Problema:**
- Admin crea sorteos y los guarda en `/admin_client/priv/data/`
- Server no sabe que existe ese sorteo (está en otra carpeta)
- Player no puede ver sorteos creados por admin
- Cada operación es aislada

---

## 📋 PASOS POR HACER (Orden de prioridad)

### FASE 1: CORREGIR IMPORTS (Semana 1)

#### Paso 1.1: Crear re-exports en shared_code

**Archivo:** `shared_code/lib/azar_shared.ex`

Agregar:
```elixir
defmodule AzarShared do
  # Re-exports para simplificar imports en otros proyectos
  defdelegate validations, to: AzarShared.Utils.Validations
  defdelegate calculations, to: AzarShared.Utils.Calculations
  defdelegate json_helper, to: AzarShared.Utils.JsonHelper
  defdelegate crypto_helper, to: AzarShared.Utils.CryptoHelper
  defdelegate date_helpers, to: AzarShared.Utils.DateHelpers
  defdelegate random_helper, to: AzarShared.Utils.RandomHelper
  defdelegate money_helper, to: AzarShared.Utils.MoneyHelper
  defdelegate string_helper, to: AzarShared.Utils.StringHelper
end
```

**O crear alias module:**
```elixir
defmodule AzarShared.Validations, do: defdelegate [all], to: AzarShared.Utils.Validations
```

**Resultado:** Todos los imports seguirán funcionando sin cambios.

#### Paso 1.2: Validar imports en todos los contexts

**Archivos a revisar:**
- ✅ `server/lib/azar_server/contexts/draws/operations.ex`
- ✅ `server/lib/azar_server/contexts/audit/operations.ex`
- ✅ `admin_client/lib/azar_admin/contexts/users/operations.ex`
- ✅ `admin_client/lib/azar_admin/contexts/draws/operations.ex`
- ✅ `admin_client/lib/azar_admin/contexts/reports/operations.ex`
- ✅ `player_client/lib/azar_player/contexts/users/operations.ex`
- ✅ `player_client/lib/azar_player/contexts/purchases/operations.ex`

**Verificación:**
```bash
grep -r "alias AzarShared\." --include="*.ex" | grep -v "Utils\."
```

---

### FASE 2: DECIDIR ARQUITECTURA (Semana 1)

#### Paso 2.1: Reunión de decisión

**Preguntas a responder:**
- ¿Deben admin_client y player_client ser apps Phoenix independientes?
- ¿Deben ser librerías dentro de server?
- ¿Necesitan sus propios servidores HTTP?
- ¿Cómo se comunican entre sí?

**Opciones comparadas:**

| Aspecto | Opción A: Apps Independientes | Opción B: Librerías en Server | Opción C: HTTP Only |
|--------|:---:|:---:|:---:|
| **Compilación** | 3 mix.exs | 1 mix.exs | 3 mix.exs |
| **Deploy** | 3 servidores | 1 servidor | 3 servidores |
| **Sincronización** | Difícil | Automática | Vía API |
| **Complejidad** | Alta | Media | Media |
| **Performance** | Bueno | Excelente | Depende latencia |
| **Testing** | Más fácil | Integrado | Complex |

#### Paso 2.2: Documentar decisión

Crear archivo `docs/ARQUITECTURA_DECISION.md` con la opción elegida y justificación.

---

### FASE 3: IMPLEMENTAR OPCIÓN ELEGIDA (Semana 2-3)

#### Si se elige: Opción A (Apps Independientes)

**Paso 3.1a: Crear mix.exs en admin_client**

```elixir
defmodule AzarAdmin.MixProject do
  use Mix.Project

  def project do
    [
      app: :azar_admin,
      version: "1.0.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {AzarAdmin.Application, []}
    ]
  end

  defp deps do
    [
      {:phoenix, "~> 1.7"},
      {:phoenix_live_view, "~> 0.20"},
      {:plug_cowboy, "~> 2.6"},
      {:azar_shared, path: "../shared_code"}
    ]
  end
end
```

**Paso 3.1b: Crear application.ex**

```elixir
defmodule AzarAdmin.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Phoenix.PubSub, name: AzarAdmin.PubSub},
      {Plug.Cowboy, scheme: :http, plug: AzarAdmin.Router, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: AzarAdmin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
```

**Paso 3.1c: Crear router.ex**

```elixir
defmodule AzarAdmin.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", AzarAdmin.Controllers do
    pipe_through :api

    get "/health", HealthController, :health
    post "/users/register", UserController, :register
    post "/users/authenticate", UserController, :authenticate
    # ... resto de rutas
  end
end
```

**Paso 3.1d: Crear endpoint.ex**

Similar para player_client.

#### Si se elige: Opción B (Librerías en Server)

**Paso 3.2a: Mover admin_client → server/lib/azar_server/admin/**

```bash
mkdir -p server/lib/azar_server/admin/contexts
mkdir -p server/lib/azar_server/admin/controllers

# Mover archivos
mv admin_client/lib/azar_admin/* server/lib/azar_server/admin/
```

**Paso 3.2b: Actualizar namespaces**

Cambiar de:
```elixir
defmodule AzarAdmin.Contexts.Users.Operations
```

A:
```elixir
defmodule AzarServer.Admin.Contexts.Users.Operations
```

**Paso 3.2c: Agregar rutas en server router**

```elixir
scope "/api/v1/admin", AzarServer.Admin.Controllers do
  pipe_through :api
  # rutas admin
end

scope "/api/v1/player", AzarServer.Player.Controllers do
  pipe_through :api
  # rutas player
end
```

---

### FASE 4: CENTRALIZAR PERSISTENCIA (Semana 3)

#### Paso 4.1: Crear módulo de rutas centralizadas

**Archivo:** `shared_code/lib/azar_shared/paths.ex`

```elixir
defmodule AzarShared.Paths do
  @base_path "priv/data"

  def draws_file, do: Path.join(@base_path, "draws.json")
  def users_file, do: Path.join(@base_path, "admin_users.json")
  def players_file, do: Path.join(@base_path, "players.json")
  def tickets_file, do: Path.join(@base_path, "tickets.json")
  def audit_file, do: Path.join(@base_path, "audit.json")
  def reports_file, do: Path.join(@base_path, "reports.json")

  def ensure_directories do
    File.mkdir_p!(@base_path)
  end
end
```

#### Paso 4.2: Reemplazar rutas hardcodeadas

**Antes:**
```elixir
@draws_file "priv/data/draws.json"
```

**Después:**
```elixir
def draws_file, do: AzarShared.Paths.draws_file()
```

#### Paso 4.3: Implementar sincronización (si es necesario)

Si cada app tiene su propia BD:

**Opción 1: Event Sourcing**
- Cada cambio emite un evento
- Eventos se publican a PubSub central
- Otros componentes se suscriben y actualizan

**Opción 2: API Calls**
- Admin creó sorteo → llama POST a `/api/v1/draws`
- Server valida y persiste en BD centralizada
- Admin lee de `/api/v1/draws` (no su propia copia)

**Recomendación:** Opción 2 es más simple para 3 apps.

---

### FASE 5: IMPLEMENTAR WEBSOCKET CHANNELS (Semana 3-4)

#### Paso 5.1: Crear channels

**Archivo:** `server/lib/azar_server/channels/draws_channel.ex`

```elixir
defmodule AzarServer.DrawsChannel do
  use Phoenix.Channel

  def join("draws:all", _message, socket) do
    {:ok, socket}
  end

  def join("draw:" <> draw_id, _message, socket) do
    {:ok, socket}
  end

  def handle_in("new_draw", payload, socket) do
    broadcast!(socket, "new_draw", payload)
    {:noreply, socket}
  end
end
```

#### Paso 5.2: Registrar en endpoint

**Archivo:** `server/lib/azar_server_web/endpoint.ex`

```elixir
socket "/socket", AzarServer.UserSocket,
  websocket: true,
  longpoll: false
```

#### Paso 5.3: Crear user socket

**Archivo:** `server/lib/azar_server/channels/user_socket.ex`

```elixir
defmodule AzarServer.UserSocket do
  use Phoenix.Socket

  channel "draws:*", AzarServer.DrawsChannel
  channel "notifications:*", AzarServer.NotificationsChannel
  channel "audit:*", AzarServer.AuditChannel

  @impl true
  def connect(_params, socket) do
    {:ok, socket}
  end

  @impl true
  def id(_socket), do: nil
end
```

---

### FASE 6: AUTENTICACIÓN CENTRALIZADA (Semana 4)

#### Paso 6.1: Crear módulo Guardian

**Archivo:** `shared_code/lib/azar_shared/guardian.ex`

```elixir
defmodule AzarShared.Guardian do
  use Guardian, otp_app: :azar_shared

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    {:ok, %{id: id}}
  end
end
```

#### Paso 6.2: Crear middleware de autenticación

**Archivo:** `shared_code/lib/azar_shared/auth_middleware.ex`

```elixir
defmodule AzarShared.AuthMiddleware do
  def call(conn, _opts) do
    token = get_token(conn)
    
    case Guardian.decode_and_verify(token) do
      {:ok, claims} -> Plug.Conn.assign(conn, :current_user, claims)
      {:error, _} -> Plug.Conn.send_resp(conn, 401, "Unauthorized")
    end
  end

  defp get_token(conn) do
    Enum.find_value(conn.req_headers, fn {key, value} ->
      if key == "authorization" do
        String.replace(value, "Bearer ", "")
      end
    end)
  end
end
```

#### Paso 6.3: Agregar middleware en routers

En cada app (admin, player, server):

```elixir
pipeline :api_auth do
  plug :accepts, ["json"]
  plug AzarShared.AuthMiddleware
end

scope "/api/v1/admin", AzarAdmin.Controllers do
  pipe_through :api_auth
  # solo rutas autenticadas
end
```

---

### FASE 7: TESTING (Semana 4-5)

#### Paso 7.1: Crear tests para contexts

**Archivo:** `admin_client/test/azar_admin/contexts/users/operations_test.exs`

```elixir
defmodule AzarAdmin.Contexts.Users.OperationsTest do
  use ExUnit.Case

  test "register_admin creates valid admin" do
    params = %{
      "name" => "Juan",
      "email" => "juan@test.com",
      "password" => "password123",
      "role" => "admin"
    }

    {:ok, admin} = AzarAdmin.Contexts.Users.Operations.register_admin(params)
    assert admin.email == "juan@test.com"
    assert admin.name == "Juan"
  end

  test "register_admin fails with invalid email" do
    params = %{
      "name" => "Juan",
      "email" => "invalid-email",
      "password" => "password123"
    }

    {:error, _reason} = AzarAdmin.Contexts.Users.Operations.register_admin(params)
  end
end
```

#### Paso 7.2: Crear integration tests

Para flujos completos (admin crea sorteo → player lo ve).

#### Paso 7.3: Crear E2E tests

Con cliente HTTP real llamando endpoints.

---

### FASE 8: DOCUMENTACIÓN (Semana 5)

#### Paso 8.1: Crear API documentation

**Archivo:** `docs/API.md`

Documentar todos los endpoints con ejemplos.

#### Paso 8.2: Crear diagramas de flujo

Arquitectura, secuencias de operaciones, flujos de datos.

#### Paso 8.3: Crear README completo

Setup, instalación, ejecución, deploy.

---

## 🎯 CRONOGRAMA ESTIMADO

| Fase | Tarea | Duración | Dependencias |
|------|-------|----------|--------------|
| 1 | Corregir imports | 1 día | Ninguna |
| 2 | Decidir arquitectura | 2 días | Fase 1 ✅ |
| 3 | Implementar arquitectura | 5-7 días | Fase 2 ✅ |
| 4 | Centralizar persistencia | 3 días | Fase 3 ✅ |
| 5 | WebSocket channels | 3 días | Fase 3 ✅ |
| 6 | Autenticación centralizada | 3 días | Fase 3 ✅ |
| 7 | Testing | 5 días | Fases 3-6 ✅ |
| 8 | Documentación | 3 días | Todas ✅ |
| **TOTAL** | | **25-29 días** | |

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

### ANTES DE EMPEZAR
- [ ] Hacer backup del código actual
- [ ] Crear rama `refactor/architecture` en git
- [ ] Reunir equipo para decisión de arquitectura

### FASE 1
- [ ] Crear re-exports en shared_code
- [ ] Validar todos los imports
- [ ] Compilar y verificar no hay errores

### FASE 2
- [ ] Documentar decisión de arquitectura
- [ ] Socializar con equipo
- [ ] Obtener aprobación

### FASE 3
- [ ] Crear mix.exs/application.ex/router.ex (según opción)
- [ ] Actualizar namespaces en todo el código
- [ ] Compilar y ejecutar
- [ ] Verificar endpoints funcionen

### FASE 4
- [ ] Crear AzarShared.Paths
- [ ] Reemplazar todas las rutas hardcodeadas
- [ ] Implementar sincronización de datos

### FASE 5
- [ ] Crear channels base
- [ ] Implementar join/handle_in
- [ ] Testear con cliente WebSocket

### FASE 6
- [ ] Implementar Guardian
- [ ] Crear middleware
- [ ] Agregar en todos los routers
- [ ] Testear autenticación

### FASE 7
- [ ] Escribir tests para cada context
- [ ] Tests de integración
- [ ] Tests E2E
- [ ] Cobertura > 80%

### FASE 8
- [ ] Documentar API
- [ ] Crear diagramas
- [ ] Escribir README
- [ ] Actualizar docs/

### FINAL
- [ ] Code review
- [ ] Merge a main
- [ ] Deploy a producción
- [ ] Monitoreo

---

## 📞 PUNTOS DE CONTACTO

Para cada fase:
- **Fase 1-2:** Decisión arquitectónica
- **Fase 3:** Implementación de estructura
- **Fase 4:** Estrategia de datos
- **Fase 5-6:** Seguridad y comunicación
- **Fase 7-8:** Calidad y documentación

---

## 🔗 REFERENCIAS

- [Phoenix Documentation](https://hexdocs.pm/phoenix)
- [Elixir Pattern Matching](https://hexdocs.pm/elixir)
- [Guardian Authentication](https://hexdocs.pm/guardian)
- [Event Sourcing Pattern](https://martinfowler.com/eaaDev/EventSourcing.html)

---

**Documento actualizado:** 26 de abril, 2026
**Versión:** 1.0
**Estado:** En revisión
