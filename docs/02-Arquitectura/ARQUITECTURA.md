# Arquitectura del Sistema - Azar S.A

## 🏛️ Componentes Principales

```
                    ┌─────────────────────┐
                    │   JUGADORES         │
                    │  (Cliente Player)   │
                    └──────────┬──────────┘
                               │
                               │ HTTP/WebSocket
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
    ┌────────┐            ┌────────┐            ┌────────┐
    │Servidor│            │Servidor│            │Servidor│
    │Sorteo 1│            │Sorteo 2│            │Sorteo N│
    └────────┘            └────────┘            └────────┘
        │                      │                      │
        └──────────────────────┼──────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │ SERVIDOR CENTRAL    │
                    │ (Hub de Sorteos)    │
                    └──────────┬──────────┘
                               │
        ┌──────────────────────┼──────────────────────┐
        │                      │                      │
        ▼                      ▼                      ▼
    ┌─────────┐            ┌──────┐            ┌──────────┐
    │ ADMIN   │            │DATOS │            │ AUDITORÍA│
    │ CLIENTE │            │(JSON)│            │  (Logs)  │
    └─────────┘            └──────┘            └──────────┘
```

## 📦 Comunicación Inter-Procesos

### Servidor Central ⬌ Servidores de Sorteo

**Dirección**: Uno-a-Uno (Synchronous)
```
Servidor Central
  ├─ GenServer: Gestor de Sorteos (Supervisor)
  │   └─ Procesos: Servidor de Sorteo 1, 2, ..., N
  │       ├─ Estado: Billetes, Fracciones, Números Ganadores
  │       ├─ Datos: Guardados en JSON
  │       └─ Métodos: comprar, devolver, ejecutar
```

### Servidor Central ⬌ Clientes (Admin/Jugador)

**Dirección**: Uno-a-Muchos (WebSocket/HTTP)
```
Servidor Central (Phoenix Channels)
  ├─ "lobby:notifications" - Notificaciones globales
  ├─ "sorteo:ID" - Actualizaciones por sorteo
  ├─ "user:ID" - Notificaciones personales
  └─ "admin:notifications" - Alertas de administrador
```

## 🔄 Flujo de Procesos

### Compra de Billete

```
1. Jugador ─────────► Cliente Player ──HTTP─► Servidor ────────────┐
                                                    │                │
2.                                                  ▼                │
                                    ┌───► Servidor de Sorteo        │
                                    │       ├─ Validar disponible   │
                                    │       ├─ Descontar billete    │
                                    │       └─ Guardar en JSON      │
                                    └───────────────────────────────┤
3. Servidor Central ─WebSocket─► Cliente Player ◄─────────────────┘
   (Confirmación/Error)
```

### Ejecución de Sorteo

```
1. Administrador ─────► Admin Client ──HTTP─► Servidor ────────────┐
   (Ejecutar Sorteo)                             │                  │
                                                 ▼                  │
2.                                  ┌───► Servidor de Sorteo        │
                                    │   ├─ Generar números ganadores│
                                    │   ├─ Calcular premios         │
                                    │   └─ Guardar estado           │
                                    └────────────────────────────────┤
3. Servidor Central ─WebSocket─► Jugadores (Notificaciones) ◄───────┘
   "¡Felicidades! Ganaste..."
```

## 📂 Estructura de Datos (JSON)

### `priv/data/sorteos.json`
```json
{
  "sorteos": [
    {
      "id": "sorteo_001",
      "nombre": "Lotería Nacional Marzo",
      "fecha_inicio": "2026-03-01",
      "fecha_ejecucion": "2026-03-15",
      "ejecutado": false,
      "valor_billete": 5000,
      "fracciones": 10,
      "cantidad_billetes": 1000,
      "billetes": [
        {"numero": 1, "disponible": true, "propietario": null},
        {"numero": 2, "disponible": false, "propietario": "user_123"}
      ],
      "premios": [
        {"id": "premio_1", "nombre": "Primer Premio", "valor": 500000}
      ],
      "numeros_ganadores": [42, 157, 389],
      "ganadores": [
        {"numero": 42, "propietario": "user_456", "premio": "premio_1"}
      ]
    }
  ]
}
```

### `priv/data/usuarios.json` (Cliente Jugador)
```json
{
  "usuarios": [
    {
      "id": "user_123",
      "nombre": "Juan Pérez",
      "documento": "12345678",
      "password_hash": "hash_bcrypt",
      "tarjeta": {
        "numero": "**** **** **** 1234",
        "vencimiento": "12/25"
      },
      "compras": [
        {
          "sorteo_id": "sorteo_001",
          "tipo": "billete_completo",
          "numero": 2,
          "valor": 5000,
          "fecha": "2026-03-05T10:30:00Z"
        }
      ],
      "premios_obtenidos": [
        {
          "sorteo_id": "sorteo_001",
          "premio": "premio_1",
          "valor": 500000,
          "fecha": "2026-03-15T20:00:00Z"
        }
      ]
    }
  ]
}
```

## 🔐 Supervisores y Procesos

```
application_supervisor
├── DistributedSorteoSupervisor (one_for_one)
│   ├── SorteoServer (Sorteo 1)
│   ├── SorteoServer (Sorteo 2)
│   └── SorteoServer (Sorteo N)
├── PresenceSupervisor
│   └── Presence Tracker
├── EndpointSupervisor
│   └── HTTP Endpoint
└── ChannelSupervisor
    └── Channel Processes
```

## 🔄 Concurrencia con Elixir

- **Procesos**: Cada sorteo es un proceso independiente
- **Mensajes**: Comunicación asíncrona entre procesos
- **Supervisores**: Manejo automático de fallos
- **Hot Reload**: Actualización de código en vivo (desarrollo)

## 📊 Estados de Sorteo

```
    ┌─────────────┐
    │   CREADO    │
    └──────┬──────┘
           │ crear_sorteo()
           ▼
    ┌─────────────┐
    │  ABIERTO    │ ◄─ Jugadores compran
    │             │ ◄─ Admin gestiona premios
    └──────┬──────┘
           │ ejecutar_sorteo()
           ▼
    ┌─────────────┐
    │  EJECUTADO  │ ─► Notificación de ganadores
    └──────┬──────┘
           │ archivar_sorteo()
           ▼
    ┌─────────────┐
    │  ARCHIVADO  │
    └─────────────┘
```

---

**Responsable**: Equipo Azar S.A  
**Versión**: 1.0  
**Fecha**: Abril 2026
