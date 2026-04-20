# Servidor Central - Azar S.A

## 📋 Descripción

Aplicación Phoenix que actúa como hub central del sistema. Gestiona:
- Supervisores de sorteos dinámicos
- Redirección de solicitudes a servidores especializados
- Notificaciones en tiempo real (WebSocket)
- Auditoría y logging de operaciones

## 🏗️ Estructura de Directorios

```
server/
├── config/                  # Configuración por entorno
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   └── test.exs
│
├── lib/azar_server/
│   ├── contexts/           # Lógica de negocio
│   │   ├── sorteos/        # Gestión de sorteos
│   │   ├── auditoria/      # Registros de auditoría
│   │   └── notificaciones/ # Sistema de notificaciones
│   │
│   ├── supervisors/        # Procesos OTP (GenServer, Supervisor)
│   │   ├── sorteo_supervisor.ex
│   │   └── sorteo_server.ex
│   │
│   ├── channels/           # WebSocket Channels
│   │   ├── sorteo_channel.ex
│   │   ├── notificacion_channel.ex
│   │   └── user_socket.ex
│   │
│   ├── controllers/        # Controladores HTTP
│   │   ├── api_controller.ex
│   │   ├── sorteo_controller.ex
│   │   └── health_controller.ex
│   │
│   ├── application.ex      # Punto de entrada de la app
│   ├── router.ex           # Rutas
│   └── endpoint.ex         # Configuración del endpoint
│
├── priv/
│   ├── data/              # Archivos JSON de persistencia
│   │   ├── sorteos.json
│   │   └── ...
│   ├── logs/              # Archivos de auditoría/logging
│   │   └── auditoria.log
│   └── static/            # Assets estáticos
│       ├── images/
│       ├── css/
│       └── js/
│
├── test/                   # Tests
│   ├── azar_server_test.exs
│   ├── contexts/
│   ├── channels/
│   └── controllers/
│
├── mix.exs               # Dependencias y configuración
└── README.md
```

## 🔧 Mix.exs

Define dependencias principales:
- `phoenix`
- `plug_cowboy`
- `jason` (para JSON)
- `bcrypt_elixir` (para hashing)

## 📦 Contextos a Implementar

### `contexts/sorteos/`
- Crear, listar, eliminar sorteos
- Gestionar billetes y fracciones
- Ejecutar sorteos

### `contexts/auditoria/`
- Registrar todas las operaciones
- Guardar en archivos de log

### `contexts/notificaciones/`
- Enviar notificaciones a jugadores
- Broadcast de mensajes

## 🎯 Procesos OTP

### Supervisor
- Gestionar dinámicamente servidores de sorteo

### GenServer (SorteoServer)
- Un proceso por cada sorteo
- Mantener estado del sorteo
- Procesar compras

## 📡 Channels (WebSocket)

- `sorteo:ID` - Actualizaciones por sorteo
- `notificaciones` - Notificaciones globales
- `user:ID` - Mensajes personales

## 🚀 Ejecución

```bash
mix deps.get
mix compile
mix phx.server
# Servidor en http://localhost:4000
```

---

**Estructura lista para programar** 🎯
