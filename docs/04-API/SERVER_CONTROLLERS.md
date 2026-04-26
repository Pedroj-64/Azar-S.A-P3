#  Controllers del Server Central

## Resumen

Se han creado **4 controllers** para el servidor central:

1. **HealthController** - Health check (ya existía)
2. **DrawController** - Gestión de sorteos ([OK] NUEVO)
3. **AuditController** - Auditoría y logs ([OK] NUEVO)
4. **NotificationController** - Notificaciones ([OK] NUEVO)

---

## 📁 Archivos Creados

```
server/lib/azar_server/controllers/
├── health_controller.ex           # Existente - Health check
├── draw_controller.ex             # [OK] NUEVO - Sorteos
├── audit_controller.ex            # [OK] NUEVO - Auditoría
└── notification_controller.ex     # [OK] NUEVO - Notificaciones
```

---

##  Endpoints por Controller

### DrawController (7 endpoints)

#### 1. **POST /api/draws**
```bash
curl -X POST http://localhost:4000/api/draws \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "draw": {
      "name": "Sorteo Especial Abril 2026",
      "draw_date": "2026-05-01T20:00:00Z",
      "full_ticket_value": 5000,
      "fractions_count": 10,
      "total_tickets": 10000
    }
  }'

# Respuesta (201 Created)
{
  "status": "ok",
  "message": "Draw created successfully",
  "draw": {
    "id": "draw-uuid-001",
    "name": "Sorteo Especial Abril 2026",
    "draw_date": "2026-05-01T20:00:00Z",
    "created_at": "2026-04-26T10:00:00Z",
    "full_ticket_value": "5000",
    "fractions_count": 10,
    "total_tickets": 10000,
    "status": "pending",
    "executed_at": null
  }
}
```

#### 2. **GET /api/draws**
```bash
# Listar todos los sorteos con paginación
curl -X GET 'http://localhost:4000/api/draws?page=1&limit=20&status=pending' \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "draws": [...],
  "page": 1,
  "limit": 20,
  "total": 45
}
```

#### 3. **GET /api/draws/:id**
```bash
# Obtener detalles de un sorteo
curl -X GET http://localhost:4000/api/draws/draw-uuid-001 \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "draw": {
    "id": "draw-uuid-001",
    "name": "Sorteo Especial Abril 2026",
    ...
  }
}
```

#### 4. **POST /api/draws/:id/execute**
```bash
# Ejecutar sorteo (seleccionar ganadores)
curl -X POST http://localhost:4000/api/draws/draw-uuid-001/execute \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "message": "Draw executed successfully",
  "draw": {...},
  "winners_count": 100,
  "winners": [
    {
      "ticket_number": 5432,
      "fraction_number": 3,
      "user_id": "user-uuid-001",
      "prize_amount": "50000",
      "prize_category": "first_prize"
    }
  ]
}
```

#### 5. **PUT /api/draws/:id**
```bash
# Actualizar sorteo
curl -X PUT http://localhost:4000/api/draws/draw-uuid-001 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "draw": {
      "name": "Sorteo Especial Abril 2026 - Actualizado"
    }
  }'
```

#### 6. **DELETE /api/draws/:id**
```bash
# Eliminar sorteo
curl -X DELETE http://localhost:4000/api/draws/draw-uuid-001 \
  -H "Authorization: Bearer {token}"
```

#### 7. **GET /api/draws/:id/statistics**
```bash
# Estadísticas de un sorteo
curl -X GET http://localhost:4000/api/draws/draw-uuid-001/statistics \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "statistics": {
    "total_tickets_sold": 8500,
    "total_revenue": "42500000",
    "winners_count": 100,
    "total_prizes": "12500000",
    "average_ticket_sold": "5000"
  }
}
```

---

### AuditController (7 endpoints)

#### 1. **GET /api/audit/logs**
```bash
# Listar logs de auditoría con filtros
curl -X GET 'http://localhost:4000/api/audit/logs?action=create&entity_type=draw&page=1&limit=50' \
  -H "Authorization: Bearer {admin_token}"

# Parámetros de filtro:
# - action: "create", "update", "delete", "buy", "return", "execute"
# - entity_type: "draw", "ticket", "prize", "user"
# - entity_id: ID específica
# - user_id: ID del usuario que hizo la acción
# - status: "success" o "failed"

# Respuesta
{
  "status": "ok",
  "logs": [
    {
      "id": "log-uuid-001",
      "action": "create",
      "entity_type": "draw",
      "entity_id": "draw-uuid-001",
      "user_id": "admin-uuid-001",
      "user_name": "Admin User",
      "user_role": "admin",
      "description": "Sorteo creado: Sorteo Especial Abril 2026",
      "status": "success",
      "created_at": "2026-04-26T10:00:00Z"
    }
  ],
  "page": 1,
  "limit": 50,
  "total": 1250,
  "filters": { "action": "create", "entity_type": "draw" }
}
```

#### 2. **GET /api/audit/entity/:entity_type/:entity_id**
```bash
# Historial completo de cambios en una entidad
curl -X GET 'http://localhost:4000/api/audit/entity/draw/draw-uuid-001' \
  -H "Authorization: Bearer {admin_token}"

# Respuesta muestra todos los cambios en el sorteo
{
  "status": "ok",
  "entity_type": "draw",
  "entity_id": "draw-uuid-001",
  "changes": [
    {
      "id": "log-001",
      "action": "create",
      "old_value": null,
      "new_value": { "name": "Sorteo Especial..." },
      "created_at": "2026-04-26T10:00:00Z"
    },
    {
      "id": "log-002",
      "action": "update",
      "old_value": { "status": "pending" },
      "new_value": { "status": "executed" },
      "created_at": "2026-05-01T20:30:00Z"
    }
  ],
  "total": 2
}
```

#### 3. **GET /api/audit/user/:user_id**
```bash
# Actividad de un usuario específico
curl -X GET 'http://localhost:4000/api/audit/user/admin-uuid-001' \
  -H "Authorization: Bearer {admin_token}"

# Respuesta
{
  "status": "ok",
  "user_id": "admin-uuid-001",
  "activity": [...],
  "total": 342
}
```

#### 4. **GET /api/audit/logs/:id**
```bash
# Detalles de un log específico
curl -X GET http://localhost:4000/api/audit/logs/log-uuid-001 \
  -H "Authorization: Bearer {admin_token}"
```

#### 5. **GET /api/audit/report**
```bash
# Generar reporte de auditoría por período
curl -X GET 'http://localhost:4000/api/audit/report?from_date=2026-04-01T00:00:00Z&to_date=2026-04-26T23:59:59Z&group_by=action' \
  -H "Authorization: Bearer {admin_token}"

# Parámetros:
# - from_date: ISO8601
# - to_date: ISO8601
# - group_by: "action", "entity_type", "user"

# Respuesta
{
  "status": "ok",
  "report": {
    "create": 45,
    "update": 123,
    "delete": 2,
    "buy": 1200,
    "return": 50,
    "execute": 5
  },
  "period": {
    "from": "2026-04-01T00:00:00Z",
    "to": "2026-04-26T23:59:59Z"
  },
  "grouped_by": "action"
}
```

#### 6. **GET /api/audit/summary**
```bash
# Resumen de auditoría (últimas 24 horas)
curl -X GET http://localhost:4000/api/audit/summary \
  -H "Authorization: Bearer {admin_token}"

# Respuesta
{
  "status": "ok",
  "summary": {
    "total_actions_24h": 450,
    "failed_actions": 3,
    "success_rate": "99.33%",
    "top_action": "buy",
    "top_entity": "ticket",
    "most_active_user": "admin-uuid-001"
  }
}
```

---

### NotificationController (9 endpoints)

#### 1. **POST /api/notifications**
```bash
# Enviar notificación a un usuario
curl -X POST http://localhost:4000/api/notifications \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "notification": {
      "user_id": "player-uuid-001",
      "type": "draw_winner",
      "title": "¡Felicitaciones!",
      "message": "Ganaste en el sorteo de hoy",
      "data": {
        "draw_id": "draw-uuid-001",
        "prize_amount": "50000",
        "ticket_number": 5432
      },
      "priority": "high"
    }
  }'

# Tipos disponibles:
# - "purchase_confirmation": confirmación de compra
# - "purchase_failed": error en compra
# - "draw_executed": sorteo ejecutado
# - "draw_winner": usuario ganó
# - "draw_loser": usuario no ganó
# - "return_confirmation": confirmación de devolución
# - "admin_alert": alertas para admin
# - "system_message": mensajes del sistema

# Respuesta (201 Created)
{
  "status": "ok",
  "message": "Notification sent successfully",
  "notification_id": "notif-uuid-001"
}
```

#### 2. **GET /api/notifications/user/:user_id**
```bash
# Listar notificaciones de un usuario
curl -X GET 'http://localhost:4000/api/notifications/user/player-uuid-001?page=1&limit=30&read=false' \
  -H "Authorization: Bearer {token}"

# Parámetros:
# - type: filtrar por tipo
# - read: true/false (leídas/no leídas)
# - page, limit: paginación

# Respuesta
{
  "status": "ok",
  "notifications": [
    {
      "id": "notif-uuid-001",
      "user_id": "player-uuid-001",
      "type": "draw_winner",
      "title": "¡Felicitaciones!",
      "message": "Ganaste en el sorteo de hoy",
      "priority": "high",
      "read": false,
      "read_at": null,
      "created_at": "2026-04-26T10:00:00Z",
      "expires_at": "2026-04-27T10:00:00Z"
    }
  ],
  "page": 1,
  "limit": 30,
  "total": 150,
  "unread_count": 5
}
```

#### 3. **GET /api/notifications/:id**
```bash
# Obtener detalles de una notificación
curl -X GET http://localhost:4000/api/notifications/notif-uuid-001 \
  -H "Authorization: Bearer {token}"
```

#### 4. **POST /api/notifications/:id/read**
```bash
# Marcar notificación como leída
curl -X POST http://localhost:4000/api/notifications/notif-uuid-001/read \
  -H "Authorization: Bearer {token}"
```

#### 5. **POST /api/notifications/user/:user_id/read-all**
```bash
# Marcar todas como leídas
curl -X POST http://localhost:4000/api/notifications/user/player-uuid-001/read-all \
  -H "Authorization: Bearer {token}"
```

#### 6. **DELETE /api/notifications/:id**
```bash
# Eliminar notificación
curl -X DELETE http://localhost:4000/api/notifications/notif-uuid-001 \
  -H "Authorization: Bearer {token}"
```

#### 7. **DELETE /api/notifications/user/:user_id**
```bash
# Eliminar todas las notificaciones de un usuario
curl -X DELETE http://localhost:4000/api/notifications/user/player-uuid-001 \
  -H "Authorization: Bearer {admin_token}"
```

#### 8. **GET /api/notifications/user/:user_id/summary**
```bash
# Resumen de notificaciones del usuario
curl -X GET http://localhost:4000/api/notifications/user/player-uuid-001/summary \
  -H "Authorization: Bearer {token}"

# Respuesta
{
  "status": "ok",
  "summary": {
    "total": 150,
    "unread": 5,
    "by_type": {
      "draw_winner": 3,
      "draw_loser": 15,
      "purchase_confirmation": 85,
      "purchase_failed": 2,
      "system_message": 40
    },
    "by_priority": {
      "high": 10,
      "normal": 130,
      "low": 10
    }
  }
}
```

#### 9. **POST /api/notifications/broadcast**
```bash
# Enviar notificación a múltiples usuarios
curl -X POST http://localhost:4000/api/notifications/broadcast \
  -H "Authorization: Bearer {admin_token}" \
  -H "Content-Type: application/json" \
  -d '{
    "broadcast": {
      "user_ids": ["user-1", "user-2", "user-3"],
      "type": "system_message",
      "title": "Mantenimiento Programado",
      "message": "Sistema estará en mantenimiento el 27 de abril",
      "data": {
        "maintenance_start": "2026-04-27T22:00:00Z",
        "expected_duration": "2 hours"
      }
    }
  }'

# Respuesta
{
  "status": "ok",
  "message": "Broadcast notification sent",
  "recipients_count": 3
}
```

---

## 🔗 Integración en Router

Agregar estas rutas en `server/lib/azar_server/router.ex`:

```elixir
defmodule AzarServerWeb.Router do
  use AzarServerWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :api_auth do
    plug :accepts, ["json"]
    plug AzarServerWeb.Plugs.AuthPlug
  end

  # Rutas públicas
  scope "/", AzarServerWeb do
    get "/health", HealthController, :health
  end

  # Rutas de API privadas (requieren autenticación)
  scope "/api", AzarServerWeb do
    pipe_through :api_auth

    # Draw endpoints
    get "/draws", DrawController, :list
    post "/draws", DrawController, :create
    get "/draws/:id", DrawController, :show
    put "/draws/:id", DrawController, :update
    delete "/draws/:id", DrawController, :delete
    post "/draws/:id/execute", DrawController, :execute
    get "/draws/:id/statistics", DrawController, :statistics

    # Audit endpoints (solo admin)
    pipe_through :admin_only
    get "/audit/logs", AuditController, :list
    get "/audit/logs/:id", AuditController, :show
    get "/audit/entity/:entity_type/:entity_id", AuditController, :by_entity
    get "/audit/user/:user_id", AuditController, :by_user
    get "/audit/report", AuditController, :report
    get "/audit/summary", AuditController, :summary

    # Notification endpoints
    post "/notifications", NotificationController, :send
    get "/notifications/:id", NotificationController, :show
    get "/notifications/user/:user_id", NotificationController, :list_user_notifications
    post "/notifications/:id/read", NotificationController, :mark_as_read
    post "/notifications/user/:user_id/read-all", NotificationController, :mark_all_as_read
    delete "/notifications/:id", NotificationController, :delete
    delete "/notifications/user/:user_id", NotificationController, :delete_all
    get "/notifications/user/:user_id/summary", NotificationController, :summary
    post "/notifications/broadcast", NotificationController, :broadcast
  end
end

# Pipeline para verificar que es admin
pipeline :admin_only do
  plug AzarServerWeb.Plugs.AdminOnlyPlug
end
```

---

##  Estado de Controllers

| Controller | Líneas | Endpoints | Estado |
|-----------|--------|-----------|--------|
| HealthController | 23 | 1 | [OK] Existente |
| DrawController | 250+ | 7 | [OK] NUEVO |
| AuditController | 280+ | 6 | [OK] NUEVO |
| NotificationController | 320+ | 9 | [OK] NUEVO |
| **TOTAL** | **870+** | **23** | [OK] COMPLETO |

---

##  Próximos Pasos

1. [OK] Controllers creados
2. [CAMBIAR] Implementar operaciones en contexts (si no existen)
3. [CAMBIAR] Configurar router.ex
4. [CAMBIAR] Crear middleware de autorización (admin_only)
5. [CAMBIAR] Crear tests para endpoints
6. [CAMBIAR] Documentar con Swagger/OpenAPI

---

**Última actualización**: 26 de abril de 2026
