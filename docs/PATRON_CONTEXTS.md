# 🏗️ Patrón de Arquitectura - Contexts

## 📋 Introducción

Este documento explica el **patrón estándar de organización** usado en el proyecto Azar S.A para construir contextos (Contexts) en Elixir/Phoenix. Este patrón garantiza consistencia, mantenibilidad y escalabilidad en todo el proyecto.

---

## 🎯 Objetivo del Patrón

Organizar el código de negocio de manera que:
- ✅ La lógica esté clara y separada por responsabilidades
- ✅ Sea fácil de encontrar y modificar código
- ✅ Se reutilicen estructuras de datos
- ✅ La API del context sea clara y predecible
- ✅ Los detalles de implementación estén ocultos

---

## 📁 Estructura Estándar de un Context

```
lib/azar_[app]/contexts/[domain]/
├── [entity].ex                 # Struct principal (entidad de negocio)
├── operations.ex               # API Pública del Context
├── operations/
│   └── operations.ex           # Implementación Privada (lógica interna)
└── schemas/                    # Esquemas relacionados
    ├── [related_entity_1].ex
    ├── [related_entity_2].ex
    └── [related_entity_3].ex
```

### Ejemplo Real (Draws Context)

```
server/lib/azar_server/contexts/draws/
├── draw.ex                     # Struct del Sorteo
├── operations.ex               # API Pública: funciones CRUD del sorteo
├── operations/
│   └── operations.ex           # Lógica privada y compleja
└── schemas/
    ├── ticket.ex              # Struct de Billete
    ├── prize.ex               # Struct de Premio
    └── fraction.ex            # Struct de Fracción
```

---

## 🔍 Detalle de Cada Archivo

### 1. **[entity].ex** - Struct Principal

**Propósito**: Definir la entidad de negocio como un struct inmutable

**Contenido**:
```elixir
defmodule AzarServer.Contexts.Draws.Draw do
  @moduledoc """
  Struct que representa un Sorteo en el sistema.
  
  Describe qué es un sorteo, sus campos y tipos.
  """

  @enforce_keys [:id, :name, :draw_date]
  defstruct [
    :id,
    :name,
    :draw_date,
    :status,
    # ... más campos
  ]

  @type t :: %__MODULE__{
    id: String.t(),
    name: String.t(),
    draw_date: DateTime.t(),
    status: String.t(),
    # ... más tipos
  }

  @doc """
  Crea una nueva instancia del struct.
  """
  def new(attrs) do
    # Lógica básica de construcción
  end
end
```

**Responsabilidades**:
- ✅ Definir campos del struct
- ✅ Definir tipos con `@type`
- ✅ Proveer función `new/1` para construcción básica
- ✅ Documentar con `@moduledoc` qué representa

**NO INCLUIR**:
- ❌ Lógica de negocio compleja
- ❌ Operaciones CRUD
- ❌ Acceso a persistencia

---

### 2. **operations.ex** - API Pública del Context

**Propósito**: Exponer la interfaz pública del context, es la única cara visible para otros módulos

**Contenido**:
```elixir
defmodule AzarServer.Contexts.Draws.Operations do
  @moduledoc """
  Operaciones de negocio para Sorteos.
  
  Maneja la lógica compleja de:
  - Crear sorteos
  - Ejecutar sorteos
  - Gestionar billetes
  
  Integración:
  - Usa validaciones de AzarShared.Validations
  - Persiste en JSON con AzarShared.JsonHelper
  """

  alias AzarServer.Contexts.Draws.Schemas.{Ticket, Prize}
  alias AzarShared.Validations

  # ============================================================================
  # OPERACIONES PÚBLICAS (Cuerpo API)
  # ============================================================================

  @doc """
  Crea un nuevo sorteo con validación completa.
  
  Parámetros:
  - name: nombre del sorteo
  - draw_date: fecha de ejecución
  
  Retorna:
  - {:ok, draw} si exitoso
  - {:error, reason} si falla
  """
  @spec create_draw(map()) :: {:ok, Draw.t()} | {:error, term()}
  def create_draw(attrs) do
    with :ok <- validate_draw_attrs(attrs),
         {:ok, draw} <- persist_draw(attrs),
         :ok <- log_audit(draw) do
      {:ok, draw}
    else
      error -> error
    end
  end

  @doc """
  Lista todos los sorteos disponibles.
  """
  @spec list_draws() :: [Draw.t()]
  def list_draws do
    # Llamar implementación privada
  end

  # Más funciones públicas...

  # ============================================================================
  # FUNCIONES PRIVADAS (Implementación oculta)
  # ============================================================================

  # Delegar a operations/operations.ex
  defp validate_draw_attrs(attrs) do
    AzarServer.Contexts.Draws.Operations.Impl.validate_draw_attrs(attrs)
  end

  defp persist_draw(attrs) do
    AzarServer.Contexts.Draws.Operations.Impl.persist_draw(attrs)
  end
end
```

**Responsabilidades**:
- ✅ Definir funciones públicas del context
- ✅ Documentar con `@spec` y `@doc`
- ✅ Manejar flujo de error (`with`)
- ✅ Integrar múltiples servicios (validación, persistencia, auditoría)
- ✅ Coordinar entre contextos si es necesario

**Patrón**:
- Funciones CRUD básicas: `create_*`, `list_*`, `get_*`, `update_*`, `delete_*`
- Operaciones de negocio: `execute_draw`, `calculate_prize`, etc.
- Cada función retorna `{:ok, result}` o `{:error, reason}`

**NO INCLUIR**:
- ❌ Lógica compleja (va en `operations/operations.ex`)
- ❌ Detalles de persistencia específicos
- ❌ Funciones privadas extensas

---

### 3. **operations/operations.ex** - Implementación Privada

**Propósito**: Contener la lógica interna y compleja, oculta del resto del proyecto

**Contenido**:
```elixir
defmodule AzarServer.Contexts.Draws.Operations.Impl do
  @moduledoc """
  Implementación interna de operaciones de sorteos.
  
  PRIVADO: No usar directamente desde otros módulos.
  Usar siempre AzarServer.Contexts.Draws.Operations
  """

  alias AzarServer.Contexts.Draws.Draw
  alias AzarServer.Contexts.Draws.Schemas.Ticket
  alias AzarShared.{Validations, JsonHelper, RandomHelper}

  # ============================================================================
  # VALIDACIONES (Privadas)
  # ============================================================================

  @doc false
  def validate_draw_attrs(attrs) do
    # Lógica de validación específica
  end

  # ============================================================================
  # PERSISTENCIA (Privadas)
  # ============================================================================

  @doc false
  def persist_draw(attrs) do
    draw = Draw.new(attrs)
    # Guardar en JSON
    JsonHelper.write_file("priv/data/draws.json", draw)
  end

  # ============================================================================
  # LÓGICA DE NEGOCIO COMPLEJA (Privadas)
  # ============================================================================

  @doc false
  def calculate_winners(draw_id, count) do
    tickets = load_tickets(draw_id)
    # Lógica compleja de selección
  end

  # ============================================================================
  # HELPERS (Privadas)
  # ============================================================================

  defp load_tickets(draw_id) do
    # Cargar tickets del JSON
  end

  defp calculate_ticket_value(base_price, fractions) do
    # Cálculos específicos
  end
end
```

**Responsabilidades**:
- ✅ Implementar lógica compleja y cálculos
- ✅ Manejar persistencia (JSON, DB, etc.)
- ✅ Operaciones internas que solo `operations.ex` llama
- ✅ Funciones marcadas con `@doc false` para que no aparezcan en documentación

**Características**:
- Todas las funciones son privadas o `@doc false`
- Contiene la verdadera complejidad del context
- Encapsulada y segura

---

### 4. **schemas/** - Estructuras Relacionadas

**Propósito**: Definir structs de entidades relacionadas que se usan dentro del context

**Ejemplo: ticket.ex**
```elixir
defmodule AzarServer.Contexts.Draws.Schemas.Ticket do
  @moduledoc """
  Struct que representa un billete dentro de un sorteo.
  
  Los billetes son las unidades vendibles en un sorteo.
  """

  @enforce_keys [:ticket_number, :draw_id, :status]
  defstruct [
    :ticket_number,
    :draw_id,
    :status,              # "available", "sold", "returned"
    :owner_id,
    :fraction_count,
    :fractions,
    :created_at
  ]

  @type t :: %__MODULE__{
    ticket_number: String.t(),
    draw_id: String.t(),
    status: String.t(),
    owner_id: String.t() | nil,
    fraction_count: integer(),
    fractions: [Fraction.t()],
    created_at: DateTime.t()
  }

  def new(attrs) do
    %__MODULE__{
      ticket_number: attrs[:ticket_number],
      draw_id: attrs[:draw_id],
      status: "available",
      created_at: DateTime.utc_now()
    }
  end
end
```

**Regla**: Crear un archivo por cada schema relacionado

```
schemas/
├── ticket.ex          # Billete
├── prize.ex          # Premio
├── fraction.ex       # Fracción
└── winner_record.ex  # Registro de ganador
```

---

## 📊 Diagrama de Relaciones

```
Otros Módulos (Controllers, Views)
           ↓
    ┌──────────────────────────────────┐
    │ operations.ex (API Pública)      │
    │ ┌────────────────────────────────┤
    │ │ create_draw/1                  │
    │ │ list_draws/0                   │
    │ │ get_draw/1                     │
    │ │ update_draw/2                  │
    │ │ execute_draw/1                 │
    │ └────────────────────────────────┤
    └──────────────┬───────────────────┘
                   ↓
         ┌─────────────────────────┐
         │ operations/operations.ex│
         │ (Lógica Privada)        │
         │ - validate_...          │
         │ - persist_...           │
         │ - calculate_...         │
         └─────────┬───────────────┘
                   ↓
         ┌─────────────────────────┐
         │ draw.ex + schemas/      │
         │ (Structs de Datos)      │
         └─────────────────────────┘
```

---

## 🔄 Flujo de una Operación

Ejemplo: Crear un nuevo sorteo

```
1. Controller recibe request HTTP
         ↓
2. Llama: Draws.Operations.create_draw(attrs)
         ↓
3. operations.ex valida flujo:
   - validate_draw_attrs(attrs)
   - persist_draw(attrs)
   - log_audit(draw)
   - Retorna {:ok, draw}
         ↓
4. operations/operations.ex ejecuta:
   - Validaciones específicas
   - Cálculos complejos
   - Persistencia en JSON
         ↓
5. Retorna resultado a operations.ex
         ↓
6. operations.ex retorna al Controller
         ↓
7. Controller retorna JSON al cliente
```

---

## ✅ Checklist para Crear un Context

Al crear un nuevo context, asegúrate de:

- [ ] **[entity].ex**: Struct principal con `@type` definido
- [ ] **operations.ex**: API pública con funciones documentadas
- [ ] **operations/operations.ex**: Implementación privada
- [ ] **schemas/**: Structs relacionados en archivos separados
- [ ] Todos usan `alias` para importar módulos
- [ ] Funciones retornan `{:ok, result}` o `{:error, reason}`
- [ ] Documentado con `@moduledoc`, `@doc`, `@spec`
- [ ] Tests en `test/` con mismo structure
- [ ] Integración con `shared_code/` para utilidades

---

## 📝 Ejemplo Completo: Purchase Context (player_client)

```
player_client/lib/azar_player/contexts/purchases/
│
├── purchase.ex
│   └── Struct: %Purchase{ id, user_id, draw_id, ...}
│
├── operations.ex
│   ├── create_purchase/1       # API Pública
│   ├── list_user_purchases/1   # API Pública
│   ├── return_purchase/1       # API Pública
│   └── [funciones privadas que llaman a operations/]
│
├── operations/
│   └── operations.ex
│       ├── validate_purchase/1        # Privada
│       ├── persist_purchase/1         # Privada
│       ├── calculate_purchase_price/1 # Privada
│       └── process_refund/1           # Privada
│
└── schemas/
    ├── refund.ex              # Struct de devolución
    ├── transaction.ex         # Struct de transacción
    └── price_breakdown.ex    # Struct de desglose de precio
```

---

## 🚫 Errores Comunes a Evitar

| ❌ MALO | ✅ BIEN |
|---------|---------|
| Todo en un archivo | Separar en operations.ex, operations/, schemas/ |
| Llamar directamente `operations/operations.ex` desde controladores | Llamar `operations.ex` que delega a `operations/` |
| Lógica sin documentación | Cada función tiene `@doc` y `@spec` |
| Funciones que retornan sólo valores | Funciones retornan `{:ok, result}` o `{:error, reason}` |
| Structs sin `@type` | Todos los structs tienen `@type t()` |
| Schemas en la raíz del context | Schemas en carpeta `schemas/` |
| Compartir código entre contexts sin `shared_code/` | Todo código reutilizable va en `shared_code/` |

---

## 🔗 Relación con shared_code/

Los contexts **siempre** usan código de `shared_code/`:

```elixir
alias AzarShared.{
  Constants,           # Valores constantes del sistema
  Validations,        # Funciones de validación comunes
  Calculations,       # Cálculos matemáticos
  JsonHelper,         # Persistencia JSON
  CryptoHelper,       # Hashing y encriptación
  RandomHelper,       # Números aleatorios
  DateHelpers         # Manipulación de fechas
}
```

---

## 📚 Referencias

- Phoenix Context Guide: https://hexdocs.pm/phoenix/contexts.html
- Domain Driven Design patterns
- Elixir Module organization

---

**Última actualización**: 26 de abril de 2026

Este patrón asegura que el proyecto tenga una **arquitectura consistente y mantenible**.
