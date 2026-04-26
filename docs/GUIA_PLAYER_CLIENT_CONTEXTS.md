# 📚 Guía de Uso - Player Client Contexts

## 🎯 Objetivo
Esta guía explica cómo usar los contexts reorganizados de `player_client/` siguiendo el patrón estándar del proyecto.

---

## 🏗️ Estructura de Carpetas

### player_client/contexts/

```
lib/azar_player/contexts/
│
├── purchases/                      # Context de Compras
│   ├── purchase.ex                # Struct principal
│   ├── operations.ex              # API Pública ⭐ USAR ESTO
│   ├── operations/
│   │   └── operations.ex          # Implementación privada
│   └── schemas/
│       ├── refund.ex
│       ├── transaction.ex
│       └── price_breakdown.ex
│
└── users/                          # Context de Usuarios
    ├── player_user.ex             # Struct principal
    ├── operations.ex              # API Pública ⭐ USAR ESTO
    ├── operations/
    │   └── operations.ex          # Implementación privada
    └── schemas/
        ├── profile.ex
        ├── credentials.ex
        └── balance_record.ex
```

---

## 📝 Cómo Usar los Contexts

### Regla de Oro ⭐

**SIEMPRE usar `operations.ex`** - Nunca acceder directamente a `operations/operations.ex`

```elixir
# ✅ CORRECTO
alias AzarPlayer.Contexts.Purchases.Operations
Operations.create_purchase(attrs)

# ❌ INCORRECTO - No hagas esto
alias AzarPlayer.Contexts.Purchases.Operations.Impl
Impl.validate_purchase_attrs(attrs)
```

---

## 💳 Context: Purchases (Compras)

### Alias Recomendado
```elixir
alias AzarPlayer.Contexts.Purchases.Operations
alias AzarPlayer.Contexts.Purchases.Purchase
alias AzarPlayer.Contexts.Purchases.Schemas.{Refund, Transaction, PriceBreakdown}
```

### Operaciones Principales

#### 1. Crear una Compra
```elixir
attrs = %{
  user_id: "user-123",
  user_name: "Juan Pérez",
  draw_id: "draw-456",
  draw_name: "Sorteo Navidad",
  purchase_type: "complete",    # o "fraction"
  ticket_number: "001",
  fraction_number: 1,            # Solo si es "fraction"
  price: 10.50
}

case Operations.create_purchase(attrs) do
  {:ok, purchase} ->
    IO.inspect(purchase)  # %Purchase{id: "...", ...}
  
  {:error, reason} ->
    IO.inspect(reason)  # "Draw is closed", etc
end
```

#### 2. Listar Compras del Jugador
```elixir
user_id = "user-123"
purchases = Operations.list_user_purchases(user_id)
# Retorna: [%Purchase{}, %Purchase{}, ...]
```

#### 3. Obtener Compra Específica
```elixir
purchase_id = "purchase-789"

case Operations.get_purchase(purchase_id) do
  {:ok, purchase} -> IO.inspect(purchase)
  {:error, :not_found} -> IO.puts("Compra no encontrada")
end
```

#### 4. Listar Compras en un Sorteo
```elixir
user_id = "user-123"
draw_id = "draw-456"

purchases = Operations.list_purchases_by_draw(user_id, draw_id)
# Retorna todas las compras de ese jugador en ese sorteo
```

#### 5. Calcular Precio
```elixir
draw_id = "draw-456"
purchase_type = "complete"
quantity = 1

case Operations.calculate_purchase_price(draw_id, purchase_type, quantity) do
  {:ok, price_breakdown} ->
    # %PriceBreakdown{
    #   base_price: 100.0,
    #   tax_amount: 10.0,
    #   commission_amount: 5.0,
    #   discount_amount: 0.0,
    #   total_price: 115.0,
    #   currency: "USD"
    # }
    IO.inspect(price_breakdown)

  {:error, reason} ->
    IO.inspect(reason)
end
```

#### 6. Verificar Disponibilidad
```elixir
user_id = "user-123"
draw_id = "draw-456"
ticket_number = "001"
purchase_type = "complete"
fraction_number = nil

case Operations.validate_purchase(user_id, draw_id, ticket_number, purchase_type, fraction_number) do
  {:ok, :available} -> IO.puts("Puedes comprar")
  {:error, :already_owned} -> IO.puts("Ya lo compraste")
  {:error, :sold_out} -> IO.puts("Vendido")
  {:error, :draw_closed} -> IO.puts("Sorteo cerrado")
end
```

#### 7. Devolver Compra
```elixir
purchase_id = "purchase-789"
reason = "Cambié de opinión"

case Operations.return_purchase(purchase_id, reason) do
  {:ok, refund} ->
    # %Refund{id: "...", refund_amount: 10.50, ...}
    IO.inspect(refund)

  {:error, reason} ->
    IO.inspect(reason)  # "Return window expired", etc
end
```

#### 8. Obtener Estadísticas
```elixir
user_id = "user-123"

stats = Operations.get_purchase_statistics(user_id)
# %{
#   total_purchases: 15,
#   total_spent: 150.50,
#   total_won: 100.00,
#   active_purchases: 3,
#   returned_purchases: 2,
#   winning_purchases: 1
# }
```

---

## 👤 Context: Users (Usuarios)

### Alias Recomendado
```elixir
alias AzarPlayer.Contexts.Users.Operations
alias AzarPlayer.Contexts.Users.PlayerUser
alias AzarPlayer.Contexts.Users.Schemas.{Profile, Credentials, BalanceRecord}
```

### Operaciones Principales

#### 1. Registrar Jugador
```elixir
attrs = %{
  full_name: "Juan Pérez",
  document_number: "12345678",
  email: "juan@example.com",
  phone: "+573101234567",
  password: "SecurePass123!"
}

case Operations.register_player(attrs) do
  {:ok, user} ->
    # %PlayerUser{
    #   id: "user-123",
    #   full_name: "Juan Pérez",
    #   status: "active",
    #   created_at: DateTime.utc_now(),
    #   ...
    # }
    IO.inspect(user)

  {:error, reason} ->
    # "Document already registered", "Invalid email", etc
    IO.inspect(reason)
end
```

#### 2. Autenticarse
```elixir
document_number = "12345678"
password = "SecurePass123!"

case Operations.authenticate(document_number, password) do
  {:ok, user} ->
    IO.inspect(user)  # Usuario autenticado

  {:error, :invalid_password} ->
    IO.puts("Contraseña incorrecta")

  {:error, :not_found} ->
    IO.puts("Usuario no existe")

  {:error, :account_suspended} ->
    IO.puts("Cuenta suspendida")
end
```

#### 3. Obtener Perfil
```elixir
user_id = "user-123"

case Operations.get_profile(user_id) do
  {:ok, profile} ->
    # %Profile{
    #   user_id: "user-123",
    #   full_name: "Juan Pérez",
    #   email: "juan@example.com",
    #   verified_email: true,
    #   ...
    # }
    IO.inspect(profile)

  {:error, :not_found} ->
    IO.puts("Usuario no existe")
end
```

#### 4. Actualizar Perfil
```elixir
user_id = "user-123"
attrs = %{
  email: "nuevo@example.com",
  phone: "+573109876543"
}

case Operations.update_profile(user_id, attrs) do
  {:ok, user} ->
    IO.inspect(user)

  {:error, reason} ->
    IO.inspect(reason)  # "Email already registered", etc
end
```

#### 5. Cambiar Contraseña
```elixir
user_id = "user-123"
old_password = "SecurePass123!"
new_password = "NewSecurePass456!"

case Operations.change_password(user_id, old_password, new_password) do
  {:ok} ->
    IO.puts("Contraseña cambiada exitosamente")

  {:error, :invalid_password} ->
    IO.puts("Contraseña actual incorrecta")

  {:error, reason} ->
    IO.inspect(reason)
end
```

#### 6. Obtener Saldo
```elixir
user_id = "user-123"

case Operations.get_balance(user_id) do
  {:ok, balance} ->
    IO.puts("Saldo: $#{balance}")

  {:error, :not_found} ->
    IO.puts("Usuario no existe")
end
```

#### 7. Agregar Saldo (Crédito)
```elixir
user_id = "user-123"
amount = 50.00
reason = "deposit"

case Operations.credit_balance(user_id, amount, reason) do
  {:ok, new_balance} ->
    IO.puts("Nuevo saldo: $#{new_balance}")

  {:error, reason} ->
    IO.inspect(reason)
end
```

#### 8. Descontar Saldo (Débito)
```elixir
user_id = "user-123"
amount = 10.50
reason = "purchase"

case Operations.debit_balance(user_id, amount, reason) do
  {:ok, new_balance} ->
    IO.puts("Nuevo saldo: $#{new_balance}")

  {:error, :insufficient_funds} ->
    IO.puts("Saldo insuficiente")

  {:error, reason} ->
    IO.inspect(reason)
end
```

#### 9. Ver Historial de Saldo
```elixir
user_id = "user-123"
limit = 50
offset = 0

history = Operations.list_balance_history(user_id, limit, offset)
# Retorna lista de BalanceRecord

Enum.each(history, fn record ->
  IO.puts("#{record.description}: #{record.amount} (#{record.transaction_type})")
end)
```

#### 10. Suspender Cuenta
```elixir
user_id = "user-123"
reason = "Violación de términos de servicio"

case Operations.suspend_account(user_id, reason) do
  {:ok} ->
    IO.puts("Cuenta suspendida")

  {:error, reason} ->
    IO.inspect(reason)
end
```

#### 11. Reactivar Cuenta
```elixir
user_id = "user-123"

case Operations.reactivate_account(user_id) do
  {:ok} ->
    IO.puts("Cuenta reactivada")

  {:error, reason} ->
    IO.inspect(reason)
end
```

#### 12. Obtener Estadísticas
```elixir
user_id = "user-123"

stats = Operations.get_statistics(user_id)
# %{
#   total_spent: 150.50,
#   total_won: 100.00,
#   purchase_count: 15,
#   winning_count: 2,
#   account_age_days: 90,
#   average_purchase_value: 10.03
# }
```

---

## 🔗 Integración en Controllers

### Ejemplo: Crear Compra desde Controller
```elixir
defmodule AzarPlayerWeb.PurchaseController do
  use AzarPlayerWeb, :controller

  alias AzarPlayer.Contexts.Purchases.Operations

  def create(conn, params) do
    case Operations.create_purchase(params) do
      {:ok, purchase} ->
        conn
        |> put_status(:created)
        |> json(%{success: true, purchase: purchase})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, error: reason})
    end
  end
end
```

---

## ⚠️ Casos de Error Comunes

| Error | Significado | Solución |
|-------|-------------|----------|
| `{:error, :not_found}` | Recurso no existe | Verifica el ID |
| `{:error, :insufficient_funds}` | Saldo insuficiente | Agregar saldo |
| `{:error, :already_owned}` | Ya compraste ese billete | Elegir otro |
| `{:error, :draw_closed}` | Sorteo ya cerrado | Esperar próximo sorteo |
| `{:error, :invalid_password}` | Contraseña incorrecta | Verificar contraseña |
| `{:error, "Email already registered"}` | Email duplicado | Usar otro email |

---

## 📊 Patrón de Manejo de Errores

Siempre usa `with` para manejar múltiples operaciones:

```elixir
with {:ok, user} <- Operations.get_profile(user_id),
     {:ok, new_balance} <- Operations.debit_balance(user_id, amount, "purchase"),
     {:ok, purchase} <- Purchases.Operations.create_purchase(purchase_attrs) do
  {:ok, purchase}
else
  {:error, :insufficient_funds} ->
    {:error, "No tienes saldo suficiente"}

  {:error, :not_found} ->
    {:error, "Usuario o recurso no encontrado"}

  {:error, reason} ->
    {:error, "Error: #{inspect(reason)}"}
end
```

---

## 🚫 NO Hagas Esto

```elixir
# ❌ NUNCA accedas directo a operations/operations.ex
alias AzarPlayer.Contexts.Purchases.Operations.Impl
Impl.validate_purchase_attrs(attrs)

# ❌ NUNCA accedas directo al struct sin usar operations
import AzarPlayer.Contexts.Purchases.Purchase
Purchase.new(attrs)  # Está bien, pero mejor usar Operations.create_purchase

# ❌ NUNCA asumas estructura de datos sin documentación
purchase.some_random_field  # ¿Existe realmente?

# ❌ NUNCA mezcles contexts sin coordinar
Operations.debit_balance  # Desde otro contexto sin consistencia
```

---

## ✅ Sí Haz Esto

```elixir
# ✅ SIEMPRE usa operations para operaciones de negocio
Operations.create_purchase(attrs)

# ✅ SIEMPRE maneja errores con pattern matching
case Operations.create_purchase(attrs) do
  {:ok, purchase} -> ...
  {:error, reason} -> ...
end

# ✅ SIEMPRE usa alias para importar
alias AzarPlayer.Contexts.Purchases.Operations

# ✅ SIEMPRE verifica tipos de datos
%Purchase{} = purchase  # Pattern matching con struct

# ✅ SIEMPRE usa with para operaciones complejas
with {:ok, user} <- ...,
     {:ok, balance} <- ... do
  ...
end
```

---

## 📚 Documentación Relacionada

- [PATRON_CONTEXTS.md](PATRON_CONTEXTS.md) - Arquitectura general
- [ESTRUCTURA_CARPETAS.md](ESTRUCTURA_CARPETAS.md) - Estructura del proyecto
- [ARQUITECTURA.md](ARQUITECTURA.md) - Diseño general del sistema

---

**Última actualización**: 26 de abril de 2026

Este documento es tu referencia rápida para usar correctamente los contexts de player_client.
