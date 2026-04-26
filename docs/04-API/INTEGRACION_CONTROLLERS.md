#  Integración de Controllers - Player Client

## Resumen

Se han creado **3 controllers** para el cliente jugador:

1. **UserController** - Gestión de usuarios (registro, login, perfil, saldo)
2. **PurchaseController** - Gestión de compras (crear, listar, devolver)
3. **HealthController** - Health check

---

## 📁 Archivos Creados

```
player_client/lib/azar_player/controllers/
├── health_controller.ex        # [OK] NUEVO - Health check
├── user_controller.ex          # [OK] NUEVO - Endpoints de usuario
└── purchase_controller.ex      # [OK] NUEVO - Endpoints de compra
```

---

##  Endpoints Disponibles

### UserController

#### 1. **POST /api/users/register**
```elixir
# Registrar nuevo jugador
curl -X POST http://localhost:4000/api/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "full_name": "Juan Pérez",
      "document_number": "1234567890",
      "email": "juan@example.com",
      "phone": "+34 600 000 000",
      "password": "SecurePassword123"
    }
  }'

# Respuesta exitosa (201 Created)
{
  "status": "ok",
  "message": "Player registered successfully",
  "user": {
    "id": "uuid-1234",
    "full_name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "+34 600 000 000",
    "account_balance": "0.00",
    "status": "active",
    "created_at": "2026-04-26T10:00:00Z"
  }
}
```

#### 2. **POST /api/users/authenticate**
```elixir
# Login
curl -X POST http://localhost:4000/api/users/authenticate \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan@example.com",
    "password": "SecurePassword123"
  }'

# Respuesta exitosa (200 OK)
{
  "status": "ok",
  "message": "Authentication successful",
  "user": {...},
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

#### 3. **GET /api/users/profile**
```elixir
# Obtener perfil (requiere autenticación)
curl -X GET http://localhost:4000/api/users/profile \
  -H "Authorization: Bearer {token}"

# Respuesta exitosa (200 OK)
{
  "status": "ok",
  "profile": {
    "user_id": "uuid-1234",
    "full_name": "Juan Pérez",
    "email": "juan@example.com",
    "phone": "+34 600 000 000",
    "document_number": "1234567890",
    "created_at": "2026-04-26T10:00:00Z",
    "verified_email": true,
    "verified_phone": true,
    "preferences": {...}
  }
}
```

#### 4. **PUT /api/users/profile**
```elixir
# Actualizar perfil
curl -X PUT http://localhost:4000/api/users/profile \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "full_name": "Juan Carlos Pérez",
      "phone": "+34 600 111 111"
    }
  }'
```

#### 5. **POST /api/users/change-password**
```elixir
# Cambiar contraseña
curl -X POST http://localhost:4000/api/users/change-password \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "old_password": "SecurePassword123",
    "new_password": "NewSecurePassword456"
  }'
```

#### 6. **GET /api/users/balance**
```elixir
# Obtener saldo disponible
curl -X GET http://localhost:4000/api/users/balance \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "balance": "1000.50"
}
```

#### 7. **GET /api/users/balance-history**
```elixir
# Obtener historial de transacciones
curl -X GET 'http://localhost:4000/api/users/balance-history?page=1&limit=20' \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "transactions": [
    {
      "id": "uuid-trans-1",
      "user_id": "uuid-1234",
      "amount": "-50.00",
      "transaction_type": "purchase",
      "description": "Purchase of ticket 5432",
      "balance_before": "1050.50",
      "balance_after": "1000.50",
      "created_at": "2026-04-26T09:30:00Z"
    }
  ],
  "page": 1,
  "limit": 20,
  "total": 45
}
```

#### 8. **GET /api/users/statistics**
```elixir
# Obtener estadísticas de cuenta
curl -X GET http://localhost:4000/api/users/statistics \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "statistics": {
    "total_spent": "500.00",
    "total_won": "1200.50",
    "number_of_purchases": 25,
    "number_of_winning_tickets": 3,
    "average_spend_per_ticket": "20.00"
  }
}
```

---

### PurchaseController

#### 1. **POST /api/purchases**
```elixir
# Crear nueva compra
curl -X POST http://localhost:4000/api/purchases \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "purchase": {
      "draw_id": "draw-001",
      "purchase_type": "complete",
      "ticket_number": 5432,
      "quantity": 2
    }
  }'

# Respuesta exitosa (201 Created)
{
  "status": "ok",
  "message": "Purchase created successfully",
  "purchase": {
    "id": "purchase-uuid-1",
    "user_id": "uuid-1234",
    "draw_id": "draw-001",
    "purchase_type": "complete",
    "ticket_number": 5432,
    "fraction_number": null,
    "price": "100.00",
    "purchase_date": "2026-04-26T10:15:00Z",
    "status": "pending",
    "price_breakdown": {
      "base_price": "80.00",
      "taxes": "16.00",
      "commissions": "4.00",
      "discounts": "0.00",
      "total": "100.00"
    }
  }
}
```

#### 2. **GET /api/purchases**
```elixir
# Listar compras del usuario
curl -X GET 'http://localhost:4000/api/purchases?page=1&limit=20' \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "purchases": [...],
  "page": 1,
  "limit": 20,
  "total": 45
}
```

#### 3. **GET /api/purchases/:id**
```elixir
# Obtener detalles de una compra
curl -X GET http://localhost:4000/api/purchases/purchase-uuid-1 \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "purchase": {...}
}
```

#### 4. **POST /api/purchases/:id/return**
```elixir
# Devolver/cancelar una compra
curl -X POST http://localhost:4000/api/purchases/purchase-uuid-1/return \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "reason": "Changed my mind"
  }'

# Respuesta
{
  "status": "ok",
  "message": "Purchase returned successfully",
  "refund": {
    "id": "refund-uuid-1",
    "purchase_id": "purchase-uuid-1",
    "refund_amount": "95.00",
    "reason": "Changed my mind",
    "status": "processed",
    "processed_date": "2026-04-26T10:20:00Z",
    "user_id": "uuid-1234"
  }
}
```

#### 5. **GET /api/purchases/refunds**
```elixir
# Listar reembolsos del usuario
curl -X GET 'http://localhost:4000/api/purchases/refunds?page=1' \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "refunds": [...],
  "page": 1,
  "limit": 20,
  "total": 5
}
```

#### 6. **GET /api/purchases/winning**
```elixir
# Listar compras ganadoras
curl -X GET 'http://localhost:4000/api/purchases/winning?page=1' \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "winning_purchases": [...],
  "page": 1,
  "limit": 20,
  "total": 3
}
```

#### 7. **GET /api/purchases/statistics**
```elixir
# Estadísticas de compras
curl -X GET http://localhost:4000/api/purchases/statistics \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "statistics": {
    "total_purchases": 25,
    "total_spent": "500.00",
    "average_ticket_price": "20.00",
    "winning_tickets": 3,
    "total_winnings": "1200.50"
  }
}
```

---

### HealthController

#### **GET /health**
```elixir
# Health check (sin autenticación)
curl -X GET http://localhost:4000/health

# Respuesta
{
  "status": "ok",
  "service": "Azar Player Client",
  "timestamp": "2026-04-26T10:30:00Z",
  "version": "0.1.0"
}
```

---

## 🔌 Integración en Router

Para integrar estos controllers en tu aplicación Phoenix, agrega las rutas en tu `router.ex`:

```elixir
defmodule AzarPlayerWeb.Router do
  use AzarPlayerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug AzarPlayerWeb.Plugs.AuthPlug  # Validar token JWT
  end

  # Rutas públicas
  scope "/", AzarPlayerWeb do
    get "/health", HealthController, :health
  end

  # Rutas de API públicas (sin autenticación)
  scope "/api", AzarPlayerWeb do
    pipe_through :api

    post "/users/register", UserController, :register
    post "/users/authenticate", UserController, :authenticate
  end

  # Rutas de API privadas (requieren autenticación)
  scope "/api", AzarPlayerWeb do
    pipe_through :api_auth

    # User endpoints
    get "/users/profile", UserController, :get_profile
    put "/users/profile", UserController, :update_profile
    post "/users/change-password", UserController, :change_password
    get "/users/balance", UserController, :get_balance
    get "/users/balance-history", UserController, :list_balance_history
    get "/users/statistics", UserController, :get_statistics

    # Purchase endpoints
    post "/purchases", PurchaseController, :create
    get "/purchases", PurchaseController, :list_user_purchases
    get "/purchases/:id", PurchaseController, :get_purchase
    post "/purchases/:id/return", PurchaseController, :return_purchase
    get "/purchases/refunds", PurchaseController, :list_refunds
    get "/purchases/winning", PurchaseController, :list_winning_purchases
    get "/purchases/statistics", PurchaseController, :get_statistics
  end
end
```

---

## 🔐 Middleware de Autenticación

Necesitas crear un plugin (plug) para validar tokens JWT:

```elixir
# lib/azar_player_web/plugs/auth_plug.ex

defmodule AzarPlayerWeb.Plugs.AuthPlug do
  @moduledoc """
  Plug para validar autenticación JWT en rutas protegidas.
  """

  import Plug.Conn

  alias AzarPlayer.Contexts.Users.Operations, as: UserOps

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "authorization") do
      [auth_header] ->
        case parse_bearer_token(auth_header) do
          {:ok, token} ->
            case UserOps.validate_session(token, DateTime.utc_now()) do
              {:ok, user} ->
                conn
                |> assign(:current_user, user)
                |> assign(:current_user_id, user.id)

              {:error, _reason} ->
                send_unauthorized(conn)
            end

          :error ->
            send_unauthorized(conn)
        end

      [] ->
        send_unauthorized(conn)
    end
  end

  defp parse_bearer_token("Bearer " <> token), do: {:ok, token}
  defp parse_bearer_token(_), do: :error

  defp send_unauthorized(conn) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(:unauthorized, Jason.encode!(%{
      status: "error",
      message: "Unauthorized"
    }))
    |> halt()
  end
end
```

---

## 🧪 Testing

Ejemplo de test para el UserController:

```elixir
# test/azar_player_web/controllers/user_controller_test.exs

defmodule AzarPlayerWeb.UserControllerTest do
  use AzarPlayerWeb.ConnCase

  setup do
    {:ok, conn: build_conn()}
  end

  describe "POST /api/users/register" do
    test "registers a new player successfully", %{conn: conn} do
      conn = post(conn, "/api/users/register", %{
        "user" => %{
          "full_name" => "Test User",
          "document_number" => "1234567890",
          "email" => "test@example.com",
          "phone" => "+34 600 000 000",
          "password" => "SecurePassword123"
        }
      })

      assert json_response(conn, 201)["status"] == "ok"
      assert json_response(conn, 201)["user"]["email"] == "test@example.com"
    end

    test "returns error on invalid data", %{conn: conn} do
      conn = post(conn, "/api/users/register", %{
        "user" => %{
          "full_name" => "Test User",
          "email" => "invalid-email"
        }
      })

      assert json_response(conn, 400)["status"] == "error"
    end
  end

  describe "POST /api/users/authenticate" do
    setup do
      # Crear usuario de prueba
      {:ok, user} = AzarPlayer.Contexts.Users.Operations.register_player(%{
        "full_name" => "Test User",
        "document_number" => "1234567890",
        "email" => "test@example.com",
        "phone" => "+34 600 000 000",
        "password" => "SecurePassword123"
      })

      {:ok, user: user}
    end

    test "authenticates user with valid credentials", %{conn: conn} do
      conn = post(conn, "/api/users/authenticate", %{
        "email" => "test@example.com",
        "password" => "SecurePassword123"
      })

      assert json_response(conn, 200)["status"] == "ok"
      assert json_response(conn, 200)["token"]
    end

    test "returns error on invalid credentials", %{conn: conn} do
      conn = post(conn, "/api/users/authenticate", %{
        "email" => "test@example.com",
        "password" => "WrongPassword"
      })

      assert json_response(conn, 401)["status"] == "error"
    end
  end
end
```

---

##  Próximos Pasos

1. [OK] **Controllers creados** (UserController, PurchaseController, HealthController)
2. [CAMBIAR] **Implementar operaciones** en operations/operations.ex
3. [CAMBIAR] **Crear tests** para los controllers
4. [CAMBIAR] **Implementar middleware** de autenticación
5. [CAMBIAR] **Configurar router** en la aplicación Phoenix
6. [CAMBIAR] **Documentar API** con Swagger/OpenAPI

---

## 📚 Referencias

- [Phoenix Controllers](https://hexdocs.pm/phoenix/controllers.html)
- [Phoenix Routing](https://hexdocs.pm/phoenix/routing.html)
- [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html)
- [JWT Authentication](https://hexdocs.pm/joken/README.html)

---

**Última actualización**: 26 de abril de 2026
