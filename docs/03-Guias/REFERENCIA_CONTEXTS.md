#  Referencia Rápida - Estructura de Contexts

##  Un Vistazo Rápido

Esta página te muestra de un vistazo cómo están organizados los contexts y cómo acceder a ellos.

---

## 📁 Estructura Visual

### player_client/contexts/purchases/

```
purchases/
│
├── 📄 purchase.ex
│   └── Struct: %Purchase{}
│       ├── id: "purchase-123"
│       ├── user_id: "user-123"
│       ├── draw_id: "draw-456"
│       ├── purchase_type: "complete"
│       └── ... más campos
│
├── 📘 operations.ex ⭐ USA ESTO
│   └── Funciones públicas:
│       ├── create_purchase/1
│       ├── list_user_purchases/1
│       ├── get_purchase/1
│       ├── return_purchase/2
│       ├── calculate_purchase_price/3
│       └── ... más funciones
│
├── operations/
│   └── 📘 operations.ex (PRIVADO - NO USES DIRECTO)
│       └── Lógica interna:
│           ├── validate_purchase_attrs/1
│           ├── persist_purchase/1
│           ├── process_refund_internal/2
│           └── ... funciones privadas
│
└── schemas/
    ├── 📄 refund.ex
    │   └── Struct: %Refund{}
    │       ├── id
    │       ├── purchase_id
    │       ├── refund_amount
    │       └── reason
    │
    ├── 📄 transaction.ex
    │   └── Struct: %Transaction{}
    │       ├── id
    │       ├── user_id
    │       ├── amount
    │       └── transaction_type
    │
    └── 📄 price_breakdown.ex
        └── Struct: %PriceBreakdown{}
            ├── base_price
            ├── tax_amount
            ├── commission_amount
            ├── discount_amount
            └── total_price
```

---

### player_client/contexts/users/

```
users/
│
├── 📄 player_user.ex
│   └── Struct: %PlayerUser{}
│       ├── id: "user-123"
│       ├── full_name: "Juan Pérez"
│       ├── document_number: "12345678"
│       ├── account_balance: 100.50
│       └── ... más campos
│
├── 📘 operations.ex ⭐ USA ESTO
│   └── Funciones públicas:
│       ├── register_player/1
│       ├── authenticate/2
│       ├── get_profile/1
│       ├── change_password/3
│       ├── credit_balance/3
│       ├── debit_balance/3
│       └── ... más funciones
│
├── operations/
│   └── 📘 operations.ex (PRIVADO - NO USES DIRECTO)
│       └── Lógica interna:
│           ├── validate_registration_attrs/1
│           ├── persist_user/1
│           ├── authenticate_internal/2
│           └── ... funciones privadas
│
└── schemas/
    ├── 📄 profile.ex
    │   └── Struct: %Profile{}
    │       ├── user_id
    │       ├── full_name
    │       ├── email
    │       └── verified_email
    │
    ├── 📄 credentials.ex ([WARN] SENSIBLE)
    │   └── Struct: %Credentials{}
    │       ├── user_id
    │       ├── password_hash
    │       ├── session_tokens
    │       └── account_locked_until
    │
    └── 📄 balance_record.ex
        └── Struct: %BalanceRecord{}
            ├── id
            ├── user_id
            ├── amount
            ├── transaction_type
            └── balance_before
```

---

## 🔄 Flujos de Uso

### Flujo 1: Comprar Billete

```
Controller HTTP
    ↓
    ├─> Operations.create_purchase(attrs)
    │       ↓
    │   operations.ex (PÚBLICO)
    │       ├─> Valida flujo
    │       ├─> Llama operations/operations.ex
    │       └─> Retorna {:ok, %Purchase{}} o {:error}
    │       ↓
    │   operations/operations.ex (PRIVADO)
    │       ├─> validate_purchase_attrs/1
    │       ├─> persist_purchase/1
    │       ├─> record_transaction/1
    │       └─> Retorna resultado
    │
    └─> Respuesta JSON al cliente
```

### Flujo 2: Registrar Jugador

```
Controller HTTP
    ↓
    ├─> Operations.register_player(attrs)
    │       ↓
    │   operations.ex (PÚBLICO)
    │       ├─> Valida flujo
    │       ├─> Llama operations/operations.ex
    │       └─> Retorna {:ok, %PlayerUser{}} o {:error}
    │       ↓
    │   operations/operations.ex (PRIVADO)
    │       ├─> validate_registration_attrs/1
    │       ├─> Hash password con CryptoHelper
    │       ├─> persist_user/1
    │       ├─> create_initial_balance/1
    │       └─> Retorna resultado
    │
    └─> Respuesta JSON al cliente
```

---

##  Matriz de Decisión

| Necesito... | Usar | Ejemplo |
|-------------|------|---------|
| Crear compra | `Operations.create_purchase/1` | `AzarPlayer.Contexts.Purchases.Operations` |
| Listar compras | `Operations.list_user_purchases/1` | `AzarPlayer.Contexts.Purchases.Operations` |
| Devolver compra | `Operations.return_purchase/2` | `AzarPlayer.Contexts.Purchases.Operations` |
| Registrar jugador | `Operations.register_player/1` | `AzarPlayer.Contexts.Users.Operations` |
| Autenticar | `Operations.authenticate/2` | `AzarPlayer.Contexts.Users.Operations` |
| Cambiar balance | `Operations.debit_balance/3` | `AzarPlayer.Contexts.Users.Operations` |
| Crear struct | `Purchase.new(attrs)` | `AzarPlayer.Contexts.Purchases.Purchase` |
| Acceder a schema | `%Refund{} = refund` | Pattern matching |

---

##  Snippets de Código

### Snippet 1: Compra Completa en Controller

```elixir
defmodule AzarPlayerWeb.PurchaseController do
  use AzarPlayerWeb, :controller

  alias AzarPlayer.Contexts.Purchases.Operations as PurchaseOps
  alias AzarPlayer.Contexts.Users.Operations as UserOps

  def create(conn, %{"purchase" => purchase_params}) do
    user_id = conn.assigns.current_user.id

    # Verificar saldo disponible
    with {:ok, balance} <- UserOps.get_balance(user_id),
         {:ok, price} <- PurchaseOps.calculate_purchase_price(
           purchase_params["draw_id"],
           purchase_params["purchase_type"],
           1
         ),
         :ok <- verify_sufficient_balance(balance, price),
         # Descontar del saldo
         {:ok, _new_balance} <- UserOps.debit_balance(
           user_id,
           price.total_price,
           "purchase"
         ),
         # Crear compra
         {:ok, purchase} <- PurchaseOps.create_purchase(
           Map.put(purchase_params, "user_id", user_id)
         ) do
      conn
      |> put_status(:created)
      |> render("show.json", purchase: purchase)
    else
      {:error, reason} ->
        render_error(conn, reason)
    end
  end

  defp verify_sufficient_balance(balance, price) do
    if balance >= price.total_price do
      :ok
    else
      {:error, :insufficient_funds}
    end
  end
end
```

### Snippet 2: Registro de Jugador

```elixir
defmodule AzarPlayerWeb.RegistrationController do
  use AzarPlayerWeb, :controller

  alias AzarPlayer.Contexts.Users.Operations

  def create(conn, %{"user" => user_params}) do
    case Operations.register_player(user_params) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> render("show.json", user: user)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{
          error: true,
          message: format_error(reason)
        })
    end
  end

  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(:insufficient_funds), do: "No tiene saldo suficiente"
  defp format_error(:not_found), do: "Usuario no encontrado"
  defp format_error(reason), do: inspect(reason)
end
```

### Snippet 3: Manejo de Errores con `with`

```elixir
def process_return(user_id, purchase_id, reason) do
  with {:ok, user} <- UserOps.get_profile(user_id),
       {:ok, purchase} <- PurchaseOps.get_purchase(purchase_id),
       :ok <- validate_purchase_belongs_to_user(purchase, user_id),
       {:ok, refund} <- PurchaseOps.return_purchase(purchase_id, reason),
       {:ok, _new_balance} <- UserOps.credit_balance(
         user_id,
         refund.refund_amount,
         "return"
       ) do
    {:ok, refund}
  else
    {:error, :not_found} ->
      {:error, "El recurso no fue encontrado"}

    {:error, :ownership_mismatch} ->
      {:error, "Esta compra no te pertenece"}

    {:error, reason} ->
      {:error, inspect(reason)}
  end
end
```

---

## 📋 Checklist: ¿Estoy Usando Correctamente los Contexts?

- [ ] ¿Estoy importando desde `operations.ex` y no desde `operations/operations.ex`?
- [ ] ¿Estoy usando `alias AzarPlayer.Contexts.Purchases.Operations`?
- [ ] ¿Estoy manejando respuestas con `{:ok, ...}` o `{:error, ...}`?
- [ ] ¿Estoy usando `with` para operaciones complejas?
- [ ] ¿Estoy usando schemas correctamente (no creando structs manualmente)?
- [ ] ¿He documentado funciones nuevas con `@spec` y `@doc`?
- [ ] ¿He incluido la lógica privada en `operations/operations.ex`?
- [ ] ¿He creado schemas en `schemas/` para estructuras relacionadas?
- [ ] ¿He registrado operaciones críticas en auditoría?

---

##  Próximos Pasos

1. **Lee** [PATRON_CONTEXTS.md](PATRON_CONTEXTS.md) para entender la arquitectura
2. **Explora** [GUIA_PLAYER_CLIENT_CONTEXTS.md](GUIA_PLAYER_CLIENT_CONTEXTS.md) para ejemplos detallados
3. **Implementa** usando el patrón estándar
4. **Valida** con el checklist arriba
5. **Documenta** tus cambios

---

**Última actualización**: 26 de abril de 2026

---

## 🔄 Apéndice: Migración de Código Antiguo

Si tienes código que usa la estructura anterior, aquí cómo actualizar:

### Cambio 1: Actualizar Imports

**[ERROR] Antes (Antiguo):**
```elixir
alias AzarPlayer.Contexts.Purchases.Purchase
purchase = Purchase.create_purchase(attrs)
```

**[OK] Después (Nuevo):**
```elixir
alias AzarPlayer.Contexts.Purchases.Operations
{:ok, purchase} = Operations.create_purchase(attrs)
```

### Cambio 2: Manejar Resultados

**[ERROR] Antes:**
```elixir
result = Purchase.create_purchase(attrs)
# ¿Qué es result? ¿Struct o error?
IO.inspect(result)
```

**[OK] Después:**
```elixir
case Operations.create_purchase(attrs) do
  {:ok, purchase} -> IO.inspect(purchase)
  {:error, reason} -> IO.inspect(reason)
end
```

### Cambio 3: Acceder a Structs Relacionados

**[ERROR] Antes:**
```elixir
refund_data = purchase.refund_amount  # ¿Existe este campo?
```

**[OK] Después:**
```elixir
# Crear explícitamente un Refund
refund = Refund.new(%{...})
%Refund{refund_amount: amount} = refund  # Pattern matching seguro
```

### Cambio 4: Manejar Errores de Forma Consistente

**[ERROR] Antes:**
```elixir
# Cada función retorna diferente
if Purchase.validate_purchase(...) do
  result = Purchase.create_purchase(...)
end
```

**[OK] Después:**
```elixir
# Todo es consistent {:ok, data} o {:error, reason}
with {:ok, :available} <- Operations.validate_purchase(...),
     {:ok, purchase} <- Operations.create_purchase(...) do
  {:ok, purchase}
else
  {:error, reason} -> {:error, reason}
end
```

### Resumen de Cambios

| Antes | Después | Razón |
|-------|---------|-------|
| `Purchase.create_purchase()` | `Operations.create_purchase()` | API clara |
| Retorna valor directo | Retorna `{:ok, ...}` o `{:error, ...}` | Manejo de errores consistente |
| Campos mezclados | Schemas separados | Organización |
| Funciones públicas/privadas sin distinción | `operations.ex` pública, `operations/` privada | Privacidad |
| Sin documentación @spec | Con `@spec` y `@doc` | Autodocumentado |

---

**Última actualización**: 26 de abril de 2026
