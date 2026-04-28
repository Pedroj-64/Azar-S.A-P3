# JSON Schemas

Definición de estructura para todos los archivos JSON utilizados en el sistema.

Fecha: 28 de abril de 2026

---

## Overview

Todos los archivos JSON siguen un patrón estándar con un objeto raíz que contiene un array "items":

```json
{
  "items": [
    { "id": "...", "data": "..." }
  ]
}
```

---

## draws.json

**Ubicación:** `priv/data/draws.json`

**Descripción:** Almacena información de todos los sorteos del sistema.

**Estructura:**

```json
{
  "items": [
    {
      "id": "draw-001",
      "name": "Sorteo Especial Abril",
      "description": "Sorteo de primer trimestre",
      "status": "active",
      "draw_date": "2026-05-15T20:00:00Z",
      "created_at": "2026-04-01T10:00:00Z",
      "total_tickets": 1000,
      "ticket_price": 10.00,
      "total_investment": 10000.00,
      "prizes": [
        {
          "id": "prize-001",
          "name": "Premio Mayor",
          "amount": 5000.00,
          "quantity": 1,
          "winning_fraction": "1/1"
        }
      ]
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único del sorteo |
| name | String | Nombre del sorteo |
| description | String | Descripción detallada |
| status | String | Estado: "draft", "active", "completed", "cancelled" |
| draw_date | DateTime | Fecha y hora del sorteo |
| created_at | DateTime | Fecha de creación |
| total_tickets | Integer | Cantidad total de billetes |
| ticket_price | Decimal | Precio por billete |
| total_investment | Decimal | Inversión total (tickets * price) |
| prizes | Array | Lista de premios disponibles |

---

## purchases.json

**Ubicación:** `priv/data/purchases.json`

**Descripción:** Registro de todas las compras de billetes y fracciones realizadas por jugadores.

**Estructura:**

```json
{
  "items": [
    {
      "id": "purchase-001",
      "user_id": "player-123",
      "draw_id": "draw-001",
      "purchase_type": "full_ticket",
      "quantity": 2,
      "fraction": null,
      "unit_price": 10.00,
      "total_price": 20.00,
      "discount_applied": 0.00,
      "final_price": 20.00,
      "payment_status": "completed",
      "payment_date": "2026-04-15T14:30:00Z",
      "refund_eligible": true,
      "created_at": "2026-04-15T14:30:00Z"
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único de compra |
| user_id | String | ID del jugador que compró |
| draw_id | String | ID del sorteo |
| purchase_type | String | Tipo: "full_ticket", "fraction" |
| quantity | Integer | Cantidad de billetes/fracciones |
| fraction | String \| null | Si es fracción: "1/2", "1/4", "1/8", etc. |
| unit_price | Decimal | Precio unitario |
| total_price | Decimal | Precio total antes de descuentos |
| discount_applied | Decimal | Descuento aplicado |
| final_price | Decimal | Precio final pagado |
| payment_status | String | Estado: "pending", "completed", "failed" |
| payment_date | DateTime | Fecha del pago |
| refund_eligible | Boolean | Si puede ser reembolsado |
| created_at | DateTime | Fecha de creación |

---

## users.json

**Ubicación:** `priv/data/users.json`

**Descripción:** Almacena información de jugadores registrados en el sistema.

**Estructura:**

```json
{
  "items": [
    {
      "id": "player-123",
      "email": "player@example.com",
      "username": "player_name",
      "full_name": "Juan Pérez",
      "password_hash": "hashed_password_here",
      "status": "active",
      "balance": 500.00,
      "total_spent": 1200.00,
      "total_won": 800.00,
      "registration_date": "2026-01-15T10:00:00Z",
      "last_login": "2026-04-28T15:30:00Z",
      "preferences": {
        "email_notifications": true,
        "sms_notifications": false
      }
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único del jugador |
| email | String | Email (unique) |
| username | String | Nombre de usuario (unique) |
| full_name | String | Nombre completo |
| password_hash | String | Password hasheado con bcrypt |
| status | String | Estado: "active", "inactive", "suspended" |
| balance | Decimal | Saldo actual disponible |
| total_spent | Decimal | Total gastado en compras |
| total_won | Decimal | Total ganado en premios |
| registration_date | DateTime | Fecha de registro |
| last_login | DateTime | Último acceso al sistema |
| preferences | Object | Preferencias del usuario |

---

## admin_users.json

**Ubicación:** `priv/data/admin_users.json`

**Descripción:** Almacena información de administradores del sistema.

**Estructura:**

```json
{
  "items": [
    {
      "id": "admin-001",
      "email": "admin@example.com",
      "username": "admin_user",
      "full_name": "Admin Principal",
      "password_hash": "hashed_password_here",
      "role": "super_admin",
      "status": "active",
      "permissions": [
        "create_draws",
        "edit_draws",
        "delete_draws",
        "view_reports",
        "manage_users"
      ],
      "registration_date": "2026-01-01T00:00:00Z",
      "last_login": "2026-04-28T16:00:00Z"
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único |
| email | String | Email (unique) |
| username | String | Nombre de usuario (unique) |
| full_name | String | Nombre completo |
| password_hash | String | Password hasheado |
| role | String | "super_admin", "admin", "analyst" |
| status | String | Estado: "active", "inactive", "suspended" |
| permissions | Array | Lista de permisos concedidos |
| registration_date | DateTime | Fecha de creación |
| last_login | DateTime | Último acceso |

---

## audit_logs.json

**Ubicación:** `priv/data/audit_logs.json`

**Descripción:** Registro de auditoría de todas las acciones importantes del sistema.

**Estructura:**

```json
{
  "items": [
    {
      "id": "audit-001",
      "action": "create",
      "entity_type": "draw",
      "entity_id": "draw-001",
      "user_id": "admin-001",
      "user_name": "Admin Principal",
      "user_role": "super_admin",
      "description": "Creó nuevo sorteo: Sorteo Especial Abril",
      "ip_address": "192.168.1.100",
      "status": "success",
      "error_message": null,
      "old_value": null,
      "new_value": {
        "name": "Sorteo Especial Abril",
        "total_tickets": 1000
      },
      "timestamp": "2026-04-15T10:30:00Z"
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único |
| action | String | Tipo: "create", "update", "delete", "buy", "return", "execute" |
| entity_type | String | "draw", "ticket", "prize", "user", "purchase" |
| entity_id | String | ID de la entidad afectada |
| user_id | String | ID del usuario que realizó la acción |
| user_name | String | Nombre del usuario |
| user_role | String | Rol del usuario |
| description | String | Descripción legible de la acción |
| ip_address | String | Dirección IP de origen |
| status | String | "success" o "failed" |
| error_message | String \| null | Mensaje de error si aplica |
| old_value | Object \| null | Valor anterior (para updates) |
| new_value | Object \| null | Valor nuevo (para updates) |
| timestamp | DateTime | Fecha y hora de la acción |

---

## admin_reports.json

**Ubicación:** `priv/data/admin_reports.json`

**Descripción:** Reportes financieros y análisis generados por el sistema.

**Estructura:**

```json
{
  "items": [
    {
      "id": "report-001",
      "report_type": "financial_summary",
      "period_start": "2026-04-01T00:00:00Z",
      "period_end": "2026-04-30T23:59:59Z",
      "generated_by": "admin-001",
      "total_income": 15000.00,
      "total_prizes_paid": 8000.00,
      "total_expenses": 1500.00,
      "net_margin": 5500.00,
      "total_draws": 12,
      "total_players": 150,
      "active_players": 120,
      "generated_at": "2026-04-28T18:00:00Z"
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único |
| report_type | String | "financial_summary", "draw_analysis", "player_stats" |
| period_start | DateTime | Inicio del período reportado |
| period_end | DateTime | Fin del período reportado |
| generated_by | String | ID del administrador que generó |
| total_income | Decimal | Ingresos totales |
| total_prizes_paid | Decimal | Premios pagados |
| total_expenses | Decimal | Gastos operacionales |
| net_margin | Decimal | Margen neto (ingresos - gastos - premios) |
| total_draws | Integer | Cantidad de sorteos |
| total_players | Integer | Jugadores totales |
| active_players | Integer | Jugadores activos en período |
| generated_at | DateTime | Fecha de generación |

---

## notifications.json

**Ubicación:** `priv/data/notifications.json`

**Descripción:** Historial de notificaciones enviadas a usuarios.

**Estructura:**

```json
{
  "items": [
    {
      "id": "notif-001",
      "user_id": "player-123",
      "notification_type": "draw_result",
      "title": "¡Resultados del sorteo disponibles!",
      "message": "Los resultados del Sorteo Especial ya están disponibles",
      "related_entity": {
        "type": "draw",
        "id": "draw-001"
      },
      "read": false,
      "created_at": "2026-04-28T20:00:00Z",
      "read_at": null
    }
  ]
}
```

**Campos principales:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| id | String | Identificador único |
| user_id | String | ID del usuario que recibe |
| notification_type | String | "draw_result", "purchase_confirmed", "refund", "promotional" |
| title | String | Título de la notificación |
| message | String | Cuerpo del mensaje |
| related_entity | Object | Referencia a entidad relacionada |
| read | Boolean | Si fue leída |
| created_at | DateTime | Fecha de creación |
| read_at | DateTime \| null | Fecha de lectura |

---

## Inicialización de Datos

Para inicializar la base de datos con datos de prueba, ejecutar:

```bash
mix run priv/scripts/seed_data.exs
```

Los archivos JSON se crearán automáticamente en `priv/data/` si no existen.

---

## Versionado

- **v1.0** (28/04/2026): Esquemas iniciales definidos
- Cambios futuros se documentarán aquí
