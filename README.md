# Sistema de Sorteos Azar S.A

Sistema distribuido para gestión de sorteos, clientes y apuestas usando Elixir y Phoenix.

## 📋 Descripción

**Azar S.A** es un sistema compuesto por múltiples aplicaciones que permite:
- Gestionar sorteos, premios y clientes
- Procesar compras de billetes y fracciones
- Notificar ganadores
- Generar reportes financieros

## 🏗️ Estructura del Proyecto

```
Azar S.A/
├── server/                 # Aplicación servidor central
│   ├── config/            # Configuraciones de entorno
│   ├── lib/azar_server/
│   │   ├── contexts/      # Lógica de negocio (Sorteos, Clientes, Apuestas)
│   │   ├── channels/      # WebSockets para comunicación en tiempo real
│   │   ├── controllers/   # Controladores HTTP
│   │   └── views/         # Renderización de vistas
│   ├── priv/
│   │   ├── data/          # Archivos JSON con datos de sorteos
│   │   └── static/        # Archivos estáticos
│   └── test/              # Tests unitarios
│
├── admin_client/          # Aplicación cliente para administrador
│   ├── config/
│   ├── lib/azar_admin/
│   │   ├── contexts/      # Gestión de sorteos y premios
│   │   ├── channels/
│   │   ├── controllers/
│   │   └── views/
│   ├── priv/
│   └── test/
│
├── player_client/         # Aplicación cliente para jugadores
│   ├── config/
│   ├── lib/azar_player/
│   │   ├── contexts/      # Gestión de usuarios y compras
│   │   ├── channels/
│   │   ├── controllers/
│   │   └── views/
│   ├── priv/
│   └── test/
│
├── shared_code/           # Código compartido entre aplicaciones
│   ├── lib/               # Módulos reutilizables
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
