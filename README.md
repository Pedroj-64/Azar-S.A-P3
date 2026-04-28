# Azar S.A - Proyecto Final P3 - Programación III

Sistema distribuido para gestión de sorteos usando Elixir y Phoenix.

## 🏗️ Estructura del Proyecto

```
Azar S.A/
├── README.md                         ← Estás aquí
├── docs/                             ← Documentación general
│   ├── PLAN_TRABAJO_ARQUITECTURA.md
│   ├── JSON_SCHEMAS.md
│   └── ...
│
├── shared_code/                      ← Código compartido (Elixir)
│   └── lib/azar_shared/
│
├── server/                           ← App: Panel Administrativo Central
│   ├── docs/                         ← Documentación específica
│   ├── lib/azar_server/
│   │   ├── contexts/                 ← Draws, Audit, Notifications
│   │   ├── controllers/              ← API endpoints
│   │   ├── views/                    ← HEEx templates
│   │   └── ...
│   ├── priv/
│   │   ├── data/                     ← Datos persistentes (JSON)
│   │   └── static/                   ← Assets compilados
│   ├── assets/                       ← Assets fuente (CSS, JS, i18n)
│   └── config/                       ← Configuraciones
│
├── admin_client/                     ← App: Cliente Admin (Opcional)
│   ├── lib/azar_admin/
│   ├── priv/
│   ├── assets/
│   └── ...
│
└── player_client/                    ← App: Cliente Jugadores (Opcional)
    ├── lib/azar_player/
    ├── priv/
    ├── assets/
    └── ...
```

## 🚀 Quick Start

### Server (Panel Admin)

```bash
cd server
mix setup
mix phx.server
# Acceso: http://localhost:4000
```

### Estructura de Datos (JSON)

```
server/priv/data/
├── draws.json              # Sorteos
├── purchases.json          # Compras/billetes
├── users.json              # Jugadores
├── admin_users.json        # Administradores
├── audit_logs.json         # Logs de auditoría
├── notifications.json      # Notificaciones
└── admin_reports.json      # Reportes
```

## 📚 Documentación

- **Proyecto General:** [docs/](./docs/)
- **Server:** [server/docs/](./server/docs/)
- **Arquitectura:** [docs/PLAN_TRABAJO_ARQUITECTURA.md](./docs/PLAN_TRABAJO_ARQUITECTURA.md)
- **Schemas:** [docs/JSON_SCHEMAS.md](./docs/JSON_SCHEMAS.md)

## ✨ Características

- ✓ Internacionalización (ES/EN)
- ✓ Tema claro/oscuro
- ✓ Panel administrativo responsivo
- ✓ Gestión de sorteos y premios
- ✓ Auditoría de operaciones
- ✓ Reportes financieros
- ✓ Notificaciones

## 📋 Estado

- ✓ **server/** - Estructura completa, lista para usar
- ⏳ **admin_client/** - Estructura lista, pendiente contenido
- ⏳ **player_client/** - Estructura lista, pendiente contenido
- ✓ **shared_code/** - Módulos Elixir listos

---

**Proyecto:** Programación III  
**Versión:** 1.0  
**Última actualización:** 28/04/2026
│   └── test/
│
├── docs/                  # Documentación del proyecto
│   ├── ARQUITECTURA.md
│   ├── API.md
│   ├── REQUISITOS.md
│   └── GUIA_DESARROLLO.md
│
├── scripts/               # Scripts útiles
│   ├── setup.sh
│   ├── start.sh
│   └── seed_data.exs
│
└── README.md
```

## 🚀 Componentes

### 1. **Servidor Central** (`server/`)
- Procesa solicitudes de clientes
- Redirecciona a servidores especializados por sorteo
- Gestiona múltiples sorteos con archivos JSON
- Registra auditoría de transacciones
- Envía notificaciones a jugadores

### 2. **Cliente Administrador** (`admin_client/`)
- Crear y eliminar sorteos
- Gestionar premios
- Ver reportes de ingresos
- Calcular ganancias/pérdidas
- Listar clientes por sorteo

### 3. **Cliente Jugador** (`player_client/`)
- Registrarse en el sistema
- Ver sorteos disponibles
- Comprar billetes completos o fracciones
- Ver historial de compras
- Devolver compras (si no se realizó)
- Consultar premios obtenidos

## 📦 Tecnologías

- **Lenguaje**: Elixir 1.17
- **Framework**: Phoenix
- **OTP**: Erlang/OTP 27 (Supervisores, Procesos)
- **Datos**: JSON
- **Comunicación**: WebSockets (Channels)
- **Protocolo**: HTTP/WebSocket

## 🛠️ Instalación

### Requisitos previos
- Elixir 1.17+
- Erlang/OTP 27+
- Node.js 18+ (para assets)

### Pasos

1. **Instalar dependencias:**
```bash
cd server && mix deps.get
cd ../admin_client && mix deps.get
cd ../player_client && mix deps.get
```

2. **Iniciar servidor:**
```bash
cd server && mix phx.server
```

3. **Iniciar cliente admin:**
```bash
cd admin_client && mix phx.server
```

4. **Iniciar cliente jugador:**
```bash
cd player_client && mix phx.server
```

## 📚 Documentación

- [Arquitectura del Sistema](docs/ARQUITECTURA.md)
- [API REST](docs/API.md)
- [Requisitos Funcionales](docs/REQUISITOS.md)
- [Guía de Desarrollo](docs/GUIA_DESARROLLO.md)

## 👥 Contribuciones

Este es un proyecto académico para Programación III con Elixir.

---

**Última actualización:** Abril 2026
