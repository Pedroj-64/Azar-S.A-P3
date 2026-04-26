# Guía de Inicio Rápido - Admin Client API

## Instalación y Ejecución

```bash
cd admin_client
mix deps.get
mix compile
mix phx.server
```

La aplicación estará disponible en `http://localhost:4000`

## Verificación de Disponibilidad

```bash
curl http://localhost:4000/health
```

## Flujo de Ejemplo

### 1. Registrar Administrador

```bash
curl -X POST http://localhost:4000/admin/register \
  -H "Content-Type: application/json" \
  -d '{
    "user": {
      "name": "Juan García",
      "email": "juan@azar.com",
      "password": "SecurePassword123!",
      "role": "admin"
    }
  }'
```

Respuesta esperada:
```json
{
  "status": "ok",
  "message": "Administrator registered successfully",
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Juan García",
    "email": "juan@azar.com",
    "role": "admin",
    "status": "active",
    "permissions": [...]
  }
}
```

**Login:**
```bash
curl -X POST http://localhost:4000/admin/authenticate \
  -H "Content-Type: application/json" \
  -d '{
    "email": "juan@azar.com",
    "password": "SecurePassword123!"
  }'
```

**Respuesta:**
```json
{
  "status": "ok",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {...}
}
```

**Guardar el token** (lo usarás en los próximos pasos)



### CREAR UN SORTEO

```bash
TOKEN="<token_del_paso_anterior>"

curl -X POST http://localhost:4000/draws \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "draw": {
      "name": "Sorteo Navidad 2026",
      "draw_date": "2026-12-25T20:00:00Z",
      "full_ticket_value": 10000,
      "fractions_count": 10,
      "total_tickets": 1000,
      "created_by": "550e8400-e29b-41d4-a716-446655440000"
    }
  }'
```

**Respuesta:**
```json
{
  "status": "ok",
  "message": "Draw created successfully",
  "draw": {
    "id": "660e8400-e29b-41d4-a716-446655440001",
    "name": "Sorteo Navidad 2026",
    "status": "open",
    ...
  }
}
```

**Guardar el draw.id** para los siguientes pasos



### LISTAR SORTEOS

```bash
curl -X GET http://localhost:4000/draws \
  -H "Authorization: Bearer $TOKEN"
```

**Ver por estado:**
```bash
curl -X GET http://localhost:4000/draws/status/open \
  -H "Authorization: Bearer $TOKEN"
```



### OBTENER ESTADÍSTICAS

```bash
DRAW_ID="660e8400-e29b-41d4-a716-446655440001"

curl -X GET http://localhost:4000/draws/$DRAW_ID/statistics \
  -H "Authorization: Bearer $TOKEN"
```

**Respuesta:**
```json
{
  "status": "ok",
  "statistics": {
    "draw_id": "660e8400-e29b-41d4-a716-446655440001",
    "draw_name": "Sorteo Navidad 2026",
    "status": "open",
    "total_revenue": 1500000,
    "tickets_sold": 150,
    "tickets_available": 850,
    "total_tickets": 1000,
    "estimated_payout": 450000,
    "margin": 1050000,
    "margin_percentage": 70.0
  }
}
```



### EJECUTAR SORTEO (Generar Ganadores)

```bash
curl -X POST http://localhost:4000/draws/$DRAW_ID/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "draw_id": "660e8400-e29b-41d4-a716-446655440001",
    "winning_numbers": [123, 456, 789, 234, 567],
    "executed_by": "550e8400-e29b-41d4-a716-446655440000"
  }'
```



### GENERAR REPORTES

**Reporte Financiero:**
```bash
curl -X POST http://localhost:4000/reports/financial \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "period_start": "2026-01-01T00:00:00Z",
    "period_end": "2026-12-31T23:59:59Z",
    "generated_by": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Análisis de Sorteo:**
```bash
curl -X POST http://localhost:4000/reports/draw-analysis \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "draw_id": "660e8400-e29b-41d4-a716-446655440001",
    "generated_by": "550e8400-e29b-41d4-a716-446655440000"
  }'
```

**Listar reportes:**
```bash
curl -X GET http://localhost:4000/reports \
  -H "Authorization: Bearer $TOKEN"
```



## Script Python para Testing

```python
#!/usr/bin/env python3
import requests
import json
from datetime import datetime, timedelta

BASE_URL = "http://localhost:4000"

class AdminAPI:
    def __init__(self):
        self.token = None
        self.user_id = None
    
    def register(self, name, email, password, role="admin"):
        """Registrar nuevo administrador"""
        data = {
            "user": {
                "name": name,
                "email": email,
                "password": password,
                "role": role
            }
        }
        r = requests.post(f"{BASE_URL}/admin/register", json=data)
        print(f"- Registro: {r.status_code}")
        return r.json()
    
    def login(self, email, password):
        """Login del administrador"""
        data = {"email": email, "password": password}
        r = requests.post(f"{BASE_URL}/admin/authenticate", json=data)
        response = r.json()
        self.token = response.get("token")
        self.user_id = response["user"]["id"]
        print(f"- Login exitoso. Token: {self.token[:20]}...")
        return response
    
    def create_draw(self, name, draw_date, ticket_value=10000, total_tickets=1000):
        """Crear nuevo sorteo"""
        data = {
            "draw": {
                "name": name,
                "draw_date": draw_date,
                "full_ticket_value": ticket_value,
                "fractions_count": 10,
                "total_tickets": total_tickets,
                "created_by": self.user_id
            }
        }
        headers = {"Authorization": f"Bearer {self.token}"}
        r = requests.post(f"{BASE_URL}/draws", json=data, headers=headers)
        print(f"- Sorteo creado: {r.status_code}")
        return r.json()["draw"]
    
    def list_draws(self):
        """Listar sorteos"""
        headers = {"Authorization": f"Bearer {self.token}"}
        r = requests.get(f"{BASE_URL}/draws", headers=headers)
        draws = r.json()["draws"]
        print(f"- {len(draws)} sorteos encontrados")
        return draws
    
    def execute_draw(self, draw_id, winning_numbers):
        """Ejecutar sorteo"""
        data = {
            "draw_id": draw_id,
            "winning_numbers": winning_numbers,
            "executed_by": self.user_id
        }
        headers = {"Authorization": f"Bearer {self.token}"}
        r = requests.post(f"{BASE_URL}/draws/{draw_id}/execute", json=data, headers=headers)
        print(f"- Sorteo ejecutado: {r.status_code}")
        return r.json()["draw"]
    
    def generate_financial_report(self, start_date, end_date):
        """Generar reporte financiero"""
        data = {
            "period_start": start_date,
            "period_end": end_date,
            "generated_by": self.user_id
        }
        headers = {"Authorization": f"Bearer {self.token}"}
        r = requests.post(f"{BASE_URL}/reports/financial", json=data, headers=headers)
        print(f"- Reporte generado: {r.status_code}")
        return r.json()["report"]
    
    def get_draw_statistics(self, draw_id):
        """Obtener estadísticas del sorteo"""
        headers = {"Authorization": f"Bearer {self.token}"}
        r = requests.get(f"{BASE_URL}/draws/{draw_id}/statistics", headers=headers)
        stats = r.json()["statistics"]
        print(f"- Estadísticas obtenidas")
        print(f"  Revenue: ${stats['total_revenue']}")
        print(f"  Margin: ${stats['margin']} ({stats['margin_percentage']}%)")
        return stats

if __name__ == "__main__":
    api = AdminAPI()
    
    # 1. Registrar
    api.register("Admin Test", "admin@test.com", "SecurePassword123!")
    
    # 2. Login
    api.login("admin@test.com", "SecurePassword123!")
    
    # 3. Crear sorteo
    tomorrow = (datetime.utcnow() + timedelta(days=1)).isoformat() + "Z"
    draw = api.create_draw("Sorteo Test", tomorrow)
    print(f"- Draw ID: {draw['id']}")
    
    # 4. Listar sorteos
    api.list_draws()
    
    # 5. Obtener estadísticas
    api.get_draw_statistics(draw["id"])
    
    # 6. Ejecutar sorteo
    api.execute_draw(draw["id"], [100, 200, 300, 400, 500])
    
    # 7. Generar reporte
    today = datetime.utcnow().isoformat() + "Z"
    api.generate_financial_report(today, today)
    
    print("\n- Test completado exitosamente!")
```

**Ejecutar:**
```bash
python3 test_api.py
```



## Testing con Postman

**Importar esta colección en Postman:**

```json
{
  "info": {
    "name": "Admin Client API",
    "version": "1.0"
  },
  "item": [
    {
      "name": "Health Check",
      "request": {
        "method": "GET",
        "url": "{{BASE_URL}}/health"
      }
    },
    {
      "name": "Register Admin",
      "request": {
        "method": "POST",
        "url": "{{BASE_URL}}/admin/register",
        "body": {
          "raw": "{\"user\": {\"name\": \"Juan\", \"email\": \"juan@test.com\", \"password\": \"SecurePassword123!\", \"role\": \"admin\"}}"
        }
      }
    },
    {
      "name": "Login",
      "request": {
        "method": "POST",
        "url": "{{BASE_URL}}/admin/authenticate",
        "body": {
          "raw": "{\"email\": \"juan@test.com\", \"password\": \"SecurePassword123!\"}"
        }
      }
    }
  ]
}
```

**Variables de Postman:**
```
BASE_URL = http://localhost:4000
TOKEN = <obtenido del login>
DRAW_ID = <obtenido del create>
```



## Checklist de Verificación

```
[ ] GET  /health                          → 200 OK
[ ] POST /admin/register                  → 201 Created
[ ] POST /admin/authenticate              → 200 OK
[ ] GET  /admin                           → 200 OK
[ ] POST /draws                           → 201 Created
[ ] GET  /draws                           → 200 OK
[ ] GET  /draws/:id                       → 200 OK
[ ] GET  /draws/status/open               → 200 OK
[ ] GET  /draws/:id/statistics            → 200 OK
[ ] POST /draws/:id/execute               → 200 OK
[ ] POST /reports/financial               → 201 Created
[ ] POST /reports/draw-analysis           → 201 Created
[ ] GET  /reports                         → 200 OK
```



## Solución de Problemas

### Error: "Email already registered"
```
→ Usa otro email o borra admin_users.json
```

### Error: "Draw is not open"
```
→ El sorteo ya fue ejecutado o cancelado
→ Crea un nuevo sorteo
```

### Error: "Invalid token"
```
→ Regenera el token haciendo login nuevamente
→ Verifica que el token esté en el header Authorization
```

### Error: "Draw date must be in the future"
```
→ La fecha debe ser futura
→ Usa: tomorrow = datetime.utcnow() + timedelta(days=1)
```



## 📚 Documentación Completa

Para documentación más detallada, consulta:
- [docs/API_USAGE.md](docs/API_USAGE.md) - Todos los endpoints con ejemplos
- [docs/ARQUITECTURA_INTERNA.md](docs/ARQUITECTURA_INTERNA.md) - Arquitectura interna
- [RESUMEN_IMPLEMENTACION.md](RESUMEN_IMPLEMENTACION.md) - Resumen de lo implementado



## 🎯 Próximos Pasos

1. Integrar con frontend (Next.js, React, etc.)
2. Configurar autenticación JWT avanzada
3. Implementar WebSocket para actualizaciones en tiempo real
4. Migrar a base de datos relacional
5. Configurar CI/CD
6. Deploy a producción



**¡Listo!** Ahora puedes empezar a usar la API del Admin Client. 🚀
