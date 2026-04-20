# Cliente Administrador - Azar S.A

## 📋 Descripción

Aplicación Phoenix para que administradores gestionen:
- Crear y eliminar sorteos
- Gestionar premios
- Ver reportes de ingresos
- Calcular ganancias/pérdidas
- Listar clientes por sorteo

## 🏗️ Estructura de Directorios

```
admin_client/
├── config/                 # Configuración por entorno
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   └── test.exs
│
├── lib/azar_admin/
│   ├── contexts/          # Lógica de negocio
│   │   ├── sorteos/       # Gestión de sorteos
│   │   ├── premios/       # Gestión de premios
│   │   ├── reportes/      # Reportes y cálculos
│   │   └── clientes/      # Consultas de clientes
│   │
│   ├── channels/          # WebSocket Channels
│   │   ├── admin_channel.ex
│   │   └── user_socket.ex
│   │
│   ├── controllers/       # Controladores HTTP
│   │   ├── sorteo_controller.ex
│   │   ├── premio_controller.ex
│   │   ├── reporte_controller.ex
│   │   └── auth_controller.ex
│   │
│   ├── live/              # LiveView (componentes interactivos)
│   │   ├── sorteo_live/
│   │   ├── premio_live/
│   │   └── reporte_live/
│   │
│   ├── components/        # Componentes reutilizables
│   │   ├── header.ex
│   │   ├── sidebar.ex
│   │   └── forms.ex
│   │
│   ├── application.ex
│   ├── router.ex
│   └── endpoint.ex
│
├── priv/
│   ├── data/             # Datos de administradores
│   │   └── admins.json
│   └── static/
│       ├── images/
│       ├── css/
│       └── js/
│
├── test/                  # Tests
│   ├── contexts/
│   ├── channels/
│   ├── controllers/
│   └── live/
│
├── assets/               # Assets frontend
│   ├── css/
│   ├── js/
│   └── images/
│
├── mix.exs              # Dependencias
└── README.md
```

## 🔧 Mix.exs

Dependencias principales:
- `phoenix`
- `phoenix_live_view` (para UI interactiva)
- `phoenix_html_helpers`
- `plug_cowboy`
- `jason`

## 📦 Contextos a Implementar

### `contexts/sorteos/`
- `crear_sorteo/1`
- `listar_sorteos/0`
- `eliminar_sorteo/1`
- `consultar_clientes/1`

### `contexts/premios/`
- `crear_premio/2`
- `listar_premios/1`
- `eliminar_premio/1`
- `actualizar_fecha_sistema/1`

### `contexts/reportes/`
- `ingresos_por_sorteo/1`
- `ganancias_perdidas/1`
- `balance_total/0`
- `premios_entregados/1`

### `contexts/clientes/`
- `listar_por_sorteo/1` (billetes completos)
- `listar_fracciones/1` (compradores de fracciones)

## 🎨 LiveView

Implementar UI dinámica sin recargas:
- Tablas de sorteos
- Formularios de creación
- Gráficos de reportes
- Búsqueda en tiempo real

## 🔐 Autenticación

- Login de administrador
- Sesiones
- Protección de rutas

## 📡 Comunicación

- HTTP API al servidor central
- WebSocket para notificaciones
- Actualización en tiempo real

## 🚀 Ejecución

```bash
mix deps.get
mix compile
mix phx.server
# Admin en http://localhost:4001
```

---

**Interfaz para administradores** 👨‍💼
