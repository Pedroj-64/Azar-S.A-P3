# Cliente Jugador - Azar S.A

## 📋 Descripción

Aplicación Phoenix para que jugadores:
- Registrarse en el sistema
- Ver sorteos disponibles
- Comprar billetes completos o fracciones
- Ver historial de compras
- Devolver compras
- Consultar premios ganados
- Ver notificaciones de resultados

## 🏗️ Estructura de Directorios

```
player_client/
├── config/                 # Configuración por entorno
│   ├── config.exs
│   ├── dev.exs
│   ├── prod.exs
│   └── test.exs
│
├── lib/azar_player/
│   ├── contexts/          # Lógica de negocio
│   │   ├── usuarios/      # Gestión de usuarios
│   │   ├── compras/       # Historial de compras
│   │   ├── sorteos/       # Consulta de sorteos disponibles
│   │   ├── premios/       # Consulta de premios ganados
│   │   └── notificaciones/# Notificaciones personales
│   │
│   ├── channels/          # WebSocket Channels
│   │   ├── user_channel.ex
│   │   ├── sorteo_channel.ex
│   │   └── user_socket.ex
│   │
│   ├── controllers/       # Controladores HTTP
│   │   ├── auth_controller.ex   # Login/Registro
│   │   ├── sorteo_controller.ex
│   │   ├── compra_controller.ex
│   │   ├── usuario_controller.ex
│   │   └── premio_controller.ex
│   │
│   ├── live/              # LiveView (componentes interactivos)
│   │   ├── sorteo_live/
│   │   ├── compra_live/
│   │   ├── historial_live/
│   │   └── premio_live/
│   │
│   ├── components/        # Componentes reutilizables
│   │   ├── header.ex
│   │   ├── footer.ex
│   │   ├── sorteo_card.ex
│   │   └── notificacion.ex
│   │
│   ├── application.ex
│   ├── router.ex
│   └── endpoint.ex
│
├── priv/
│   ├── data/             # Datos de jugadores (local)
│   │   └── usuarios.json
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
- `bcrypt_elixir`

## 📦 Contextos a Implementar

### `contexts/usuarios/`
- `crear_usuario/1` (registro)
- `autenticar/2` (login)
- `obtener_usuario/1`
- `actualizar_usuario/2`

### `contexts/sorteos/`
- `listar_disponibles/0`
- `obtener_sorteo/1`
- `consultar_numeros/1` (billetes y fracciones disponibles)

### `contexts/compras/`
- `comprar_billete/3` (sorteo, número, usuario)
- `comprar_fraccion/4` (sorteo, billete, fracción, usuario)
- `listar_compras/1` (por usuario)
- `devolver_compra/1` (reembolso si sorteo no se ejecutó)

### `contexts/premios/`
- `listar_ganados/1` (por usuario)
- `calcular_balance/1` (total gastado vs. total ganado)

### `contexts/notificaciones/`
- `listar_notificaciones/1`
- `marcar_leida/1`
- `crear_notificacion/2`

## 🎨 LiveView

Implementar páginas dinámicas:
- Carrusel de sorteos
- Selector de números con actualización en tiempo real
- Historial de compras con filtros
- Panel de premios ganados
- Centro de notificaciones

## 🔐 Autenticación

- Registro con validación
- Login con documento/contraseña
- Sesiones de usuario
- Protección de rutas privadas

## 📱 Responsive

- Diseño mobile-first
- Compatible con tabletas
- Optimizado para navegadores modernos

## 📡 Comunicación

- HTTP API al servidor central
- WebSocket para:
  - Actualizaciones de números disponibles
  - Notificaciones de resultados
  - Cambios en sorteos

## 💳 Seguridad

- Validación de campos
- Contraseñas hasheadas (bcrypt)
- CSRF protection
- Rate limiting en compras

## 🚀 Ejecución

```bash
mix deps.get
mix compile
mix phx.server
# Player en http://localhost:4002
```

---

**Interfaz para jugadores** 🎰
