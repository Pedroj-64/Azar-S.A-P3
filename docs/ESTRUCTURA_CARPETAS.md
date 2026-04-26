# 📁 Estructura de Carpetas - Azar S.A

Este documento describe en detalle cada carpeta del proyecto, su propósito y contenido.

---

## 📋 Índice

1. [Raíz del Proyecto](#raíz-del-proyecto)
2. [server/](#server) - Aplicación Central
3. [admin_client/](#admin_client) - Cliente Administrador
4. [player_client/](#player_client) - Cliente Jugador
5. [shared_code/](#shared_code) - Código Compartido
6. [docs/](#docs) - Documentación
7. [scripts/](#scripts) - Scripts y Utilidades
8. [assets/](#assets) - Archivos de Frontend

---

## Raíz del Proyecto

### Ubicación
```
/home/ajolote/Documentos/Codigo/Azar S.A P3/
```

### Archivos Principales

| Archivo | Propósito |
|---------|-----------|
| `README.md` | Descripción general del proyecto |
| `Proyecto - Programación III (1).pdf` | Documento de requisitos y especificaciones |
| `.git/` | Control de versiones Git |

### Estructura General
```
Azar S.A/
├── server/              # Backend central (Phoenix)
├── admin_client/        # Interfaz administrador
├── player_client/       # Interfaz jugador
├── shared_code/         # Código reutilizable
├── docs/                # Documentación
├── scripts/             # Automatización
├── assets/              # Recursos front-end
└── README.md            # Descripción principal
```

---

## server/

### 📝 Propósito
Aplicación **Phoenix** central que gestiona:
- Lógica de negocio de sorteos
- Gestión de transacciones y auditoría
- Procesamiento de notificaciones
- API HTTP para clientes
- WebSockets para comunicación en tiempo real

### 🗂️ Estructura

```
server/
├── mix.exs                  # Definición del proyecto Elixir
├── README.md                # Documentación del servidor
├── config/                  # Configuración por entorno
│   ├── config.exs          # Config común
│   ├── dev.exs             # Desarrollo
│   ├── prod.exs            # Producción
│   └── test.exs            # Tests
├── lib/
│   └── azar_server/
│       ├── application.ex    # Supervisor raíz (OTP)
│       ├── endpoint.ex       # Configuración de Phoenix
│       ├── user_socket.ex    # WebSocket handler
│       ├── router.ex         # Rutas HTTP
│       ├── error_json.ex     # Formato de errores JSON
│       ├── contexts/         # Lógica de negocio
│       ├── channels/         # Canales WebSocket
│       ├── controllers/      # Controladores HTTP
│       └── views/            # Vistas/Renderización
├── priv/
│   ├── data/                # Archivos JSON de datos
│   └── static/              # Archivos CSS, JS, imágenes
│       ├── css/
│       ├── js/
│       └── images/
└── test/                    # Tests unitarios
    ├── test_helper.exs
    ├── azar_server/
    │   ├── controllers/
    │   │   └── health_controller_test.exs
    │   └── ...
    └── support/
        └── context_case.ex  # Helpers para tests
```

### 📌 Carpetas Clave

#### `lib/azar_server/contexts/`
Implementa la **lógica de negocio** mediante Context modules:

##### **audit/** - Gestión de Auditoría
```
audit/
├── audit_log.ex        # Schema de registro de auditoría
└── operations/
    └── operations.ex   # Operaciones CRUD de logs
```
**Qué se puede hacer:**
- Registrar transacciones de usuarios
- Almacenar eventos de sorteos
- Consultar historial de cambios

##### **draws/** - Gestión de Sorteos
```
draws/
├── draw.ex             # Schema principal de sorteos
├── operations.ex       # Interfaz pública del Context
├── operations/
│   └── operations.ex   # Lógica interna
└── schemas/
    ├── ...             # Esquemas relacionados
    └── ...             # Validaciones
```
**Qué se puede hacer:**
- Crear, actualizar, eliminar sorteos
- Validar datos de sorteos
- Calcular premios y ganancias
- Procesar billetes y fracciones
- Gestionar estados de sorteos (abierto, finalizado, etc.)

##### **notifications/** - Gestión de Notificaciones
```
notifications/
├── operations/
│   └── operations.ex   # Lógica de notificaciones
```
**Qué se puede hacer:**
- Enviar notificaciones a jugadores
- Registrar ganadores
- Notificar cambios de sorteos
- Integración con email/SMS

#### `lib/azar_server/channels/`
```
channels/
```
**Propósito:** WebSocket handlers para comunicación en tiempo real
- Actualmente vacío, lista para implementar

#### `lib/azar_server/controllers/`
```
controllers/
├── health_controller.ex    # Endpoint de salud del sistema
└── ...
```
**Qué se puede hacer:**
- Endpoints HTTP GET, POST, PUT, DELETE
- Validación de requests
- Retorno de respuestas JSON

#### `lib/azar_server/views/`
Renderización de respuestas HTTP (vistas JSON)

#### `priv/data/`
Almacenamiento de datos JSON:
- Información de sorteos
- Datos persistentes entre reinicios

#### `priv/static/`
Recursos estáticos:
- Estilos CSS
- Scripts JavaScript
- Imágenes

#### `test/`
Tests unitarios:
- Tests de controladores
- Tests de contextos
- Fixtures y helpers

---

## admin_client/

### 📝 Propósito
Aplicación **Phoenix** para administradores que permite:
- Crear y gestionar sorteos
- Configurar premios
- Generar reportes financieros
- Visualizar clientes activos
- Monitorear ingresos

### 🗂️ Estructura

```
admin_client/
├── README.md                # Documentación específica
├── config/
│   ├── config.exs          # Configuración común
│   ├── dev.exs             # Desarrollo
│   └── prod.exs            # Producción
├── lib/
│   └── azar_admin/
│       ├── channels/       # WebSockets para admin
│       ├── contexts/       # Lógica de negocio del admin
│       │   ├── reports/   # Generación de reportes
│       │   │   └── income_report.ex  # Cálculo de ingresos
│       │   └── users/     # Gestión de usuarios admin
│       │       └── admin_user.ex
│       ├── controllers/    # Endpoints HTTP
│       └── views/          # Renderización de vistas
├── priv/
│   ├── data/               # Datos específicos del admin
│   └── static/             # Assets del admin
│       ├── css/
│       ├── images/
│       └── js/
└── test/                   # Tests de admin
```

### 📌 Carpetas Clave

#### `lib/azar_admin/contexts/`

##### **reports/** - Generación de Reportes
```
reports/
└── income_report.ex   # Módulo para cálculo de ingresos
```
**Qué se puede hacer:**
- Calcular ingresos totales por sorteo
- Generar reportes de ganancias/pérdidas
- Estadísticas de ventas
- Informes por período de tiempo

##### **users/** - Gestión de Usuarios Admin
```
users/
└── admin_user.ex      # Schema de usuario administrador
```
**Qué se puede hacer:**
- Crear cuentas de administrador
- Gestionar permisos
- Auditar acciones de admin
- Controlar acceso a funciones

#### `priv/static/`
Interfaz gráfica:
- Dashboard del administrador
- Formularios de creación de sorteos
- Gráficos de reportes

---

## player_client/

### 📝 Propósito
Aplicación **Phoenix** para jugadores que permite:
- Registrarse en el sistema
- Ver sorteos disponibles
- Comprar billetes completos o fracciones
- Consultar historial de compras
- Devolver compras sin realizar
- Ver premios obtenidos

### 🗂️ Estructura

```
player_client/
├── README.md                # Documentación específica
├── config/
│   ├── config.exs
│   ├── dev.exs
│   └── prod.exs
├── lib/
│   └── azar_player/
│       ├── channels/       # WebSockets para jugadores
│       ├── contexts/       # Lógica de compras
│       │   ├── purchases/  # Gestión de compras
│       │   │   └── purchase.ex
│       │   └── users/      # Gestión de usuarios jugador
│       │       └── player_user.ex
│       ├── controllers/    # Endpoints HTTP
│       └── views/          # Renderización de vistas
├── priv/
│   ├── data/               # Datos de jugadores
│   └── static/             # Assets del jugador
│       ├── css/
│       ├── images/
│       └── js/
└── test/                   # Tests del cliente
```

### 📌 Carpetas Clave

#### `lib/azar_player/contexts/`

Sigue el **patrón estándar de contexts** (ver `docs/PATRON_CONTEXTS.md`)

##### **purchases/** - Gestión de Compras
```
purchases/
├── purchase.ex                 # Struct principal de Compra
├── operations.ex               # API Pública del context
├── operations/
│   └── operations.ex           # Implementación privada
└── schemas/
    ├── refund.ex              # Schema: Reembolso
    ├── transaction.ex         # Schema: Transacción
    └── price_breakdown.ex     # Schema: Desglose de precios
```
**Qué se puede hacer:**
- Crear compras de billetes (completos o fracciones)
- Validar disponibilidad de billetes
- Calcular precios y descuentos
- Procesar devoluciones y reembolsos
- Consultar historial de compras
- Verificar estado de compras (ganador, pérdida, etc)

**Funciones Públicas** (`operations.ex`):
- `create_purchase/1` - Comprar billete/fracción
- `list_user_purchases/1` - Listar compras del jugador
- `get_purchase/1` - Obtener compra específica
- `list_purchases_by_draw/2` - Compras en un sorteo
- `return_purchase/2` - Devolver compra
- `calculate_purchase_price/3` - Calcular precio
- `validate_purchase/5` - Verificar si se puede comprar
- `get_available_balance/1` - Saldo disponible
- `get_purchase_statistics/1` - Estadísticas

##### **users/** - Gestión de Usuarios Jugadores
```
users/
├── player_user.ex             # Struct principal de Usuario
├── operations.ex               # API Pública del context
├── operations/
│   └── operations.ex           # Implementación privada
└── schemas/
    ├── profile.ex             # Schema: Perfil del jugador
    ├── credentials.ex         # Schema: Credenciales (hash, tokens)
    └── balance_record.ex      # Schema: Registro de saldo
```
**Qué se puede hacer:**
- Registrar nuevos jugadores
- Autenticar jugadores
- Gestionar perfil del jugador
- Cambiar contraseñas
- Gestionar saldo y crédito
- Consultar historial de transacciones
- Suspender/reactivar cuentas
- Ver estadísticas del jugador

**Funciones Públicas** (`operations.ex`):
- `register_player/1` - Registrar nuevo jugador
- `authenticate/2` - Autenticarse
- `validate_session/2` - Validar sesión
- `get_profile/1` - Obtener perfil
- `update_profile/2` - Actualizar perfil
- `change_password/3` - Cambiar contraseña
- `get_balance/1` - Obtener saldo
- `credit_balance/3` - Agregar saldo
- `debit_balance/3` - Descontar saldo
- `list_balance_history/3` - Historial de transacciones
- `get_account_status/1` - Estado de cuenta
- `suspend_account/2` - Suspender cuenta
- `reactivate_account/1` - Reactivar cuenta
- `get_statistics/1` - Estadísticas

#### `priv/static/`
Interfaz de jugador:
- Formularios de compra
- Listado de sorteos
- Historial de compras
- Carrito de compras

---

## shared_code/

### 📝 Propósito
Librería Elixir reutilizable compartida entre todas las aplicaciones:
- Constantes del sistema
- Definiciones de errores
- Esquemas compartidos
- Utilidades generales

### 🗂️ Estructura

```
shared_code/
├── README.md
├── mix.exs              # Definición como dependencia
├── lib/
│   └── azar_shared/
│       ├── constants.ex              # Constantes globales
│       ├── errors.ex                 # Definiciones de errores
│       ├── schemas/                  # Estructuras de datos compartidas
│       │   └── notification.ex       # Schema de notificación
│       └── utils/                    # Funciones de utilidad
│           ├── calculations.ex       # Cálculos matemáticos
│           ├── crypto_helper.ex      # Funciones criptográficas
│           ├── date_helpers.ex       # Manipulación de fechas
│           ├── json_helper.ex        # Parsing/serialización JSON
│           ├── money_helper.ex       # Operaciones con dinero
│           ├── random_helper.ex      # Generación de números aleatorios
│           ├── string_helper.ex      # Manipulación de strings
│           └── validations.ex        # Validadores comunes
└── test/                # Tests de código compartido
```

### 📌 Contenido de Archivos

#### `constants.ex`
**Qué se puede encontrar:**
- Moneda del sistema (USD, COP, etc.)
- Límites de compra (máximo/mínimo por billete)
- Porcentajes de comisión
- Estados de sorteos (abierto, finalizado, cancelado)
- Roles de usuarios (admin, jugador)

#### `errors.ex`
**Qué se puede encontrar:**
- Definición de tipos de error personalizado
- Mensajes de error estandarizados
- Códigos de error para API
- Ejemplos: `:insufficient_funds`, `:invalid_ticket`, `:draw_closed`

#### `schemas/notification.ex`
**Qué se puede encontrar:**
- Estructura de datos para notificaciones
- Campos: usuario, tipo, mensaje, fecha
- Validaciones de esquema

#### `utils/calculations.ex`
**Qué se puede hacer:**
- Calcular ganancia esperada
- Calcular porcentaje de comisión
- Calcular premio final
- Operaciones matemáticas específicas del negocio

#### `utils/crypto_helper.ex`
**Qué se puede hacer:**
- Hash de contraseñas
- Generación de tokens
- Encriptación de datos sensibles

#### `utils/date_helpers.ex`
**Qué se puede hacer:**
- Validar fechas
- Calcular diferencia de tiempo
- Formatear fechas
- Verificar si un sorteo está activo

#### `utils/json_helper.ex`
**Qué se puede hacer:**
- Serializar estructuras a JSON
- Deserializar JSON a estructuras
- Validar formato JSON

#### `utils/money_helper.ex`
**Qué se puede hacer:**
- Convertir entre denominaciones
- Redondear moneda
- Calcular cambio
- Formatear moneda para visualización

#### `utils/random_helper.ex`
**Qué se puede hacer:**
- Generar números aleatorios para sorteos
- Seleccionar ganadores
- Generar identificadores únicos

#### `utils/string_helper.ex`
**Qué se puede hacer:**
- Validar formato de email
- Limpiar y normalizar strings
- Truncar strings largos
- Formatear nombres

#### `utils/validations.ex`
**Qué se puede hacer:**
- Validar email
- Validar teléfono
- Validar documento de identidad
- Validar cantidad de dinero
- Validar campos comunes

---

## docs/

### 📝 Propósito
Documentación completa del proyecto

### 🗂️ Estructura

```
docs/
├── README.md                           # Índice de documentación
├── REQUISITOS.md                       # Especificaciones del proyecto
├── ARQUITECTURA.md                     # Diseño del sistema
├── GUIA_DESARROLLO.md                  # Guía para desarrolladores
├── ESTRUCTURA_CARPETAS.md              # Este archivo
└── Structures/                         # Diagramas de arquitectura
    ├── 00_START_HERE.md               # Punto de inicio
    ├── 01_General/
    │   ├── 01_general_architecture.mmd    # Diagrama Mermaid
    │   ├── 02_complete_system_overview.mmd
    │   └── README.md
    ├── 02_PlayerClient/
    │   ├── 01_structure.mmd
    │   ├── 02_registration_flow.mmd
    │   └── README.md
    ├── 03_AdminClient/
    │   ├── 01_structure.mmd
    │   ├── 02_draw_creation_flow.mmd
    │   └── README.md
    ├── 04_Server/
    │   ├── 01_full_structure.mmd
    │   └── README.md
    ├── 05_Contexts/
    │   ├── 01_draws.mmd
    │   ├── 02_audit.mmd
    │   ├── 03_notifications.mmd
    │   └── README.md
    ├── 06_Flows/
    │   ├── 01_purchase_flow.mmd
    │   └── README.md
    └── 07_SharedCode/
        ├── 01_structure.mmd
        └── README.md
```

### 📌 Contenido de Documentos

| Archivo | Contenido |
|---------|-----------|
| `REQUISITOS.md` | Especificaciones técnicas y funcionales |
| `ARQUITECTURA.md` | Diseño general del sistema |
| `GUIA_DESARROLLO.md` | Instrucciones para desarrolladores |
| `ESTRUCTURA_CARPETAS.md` | **Este archivo** |
| `Structures/` | Diagramas y visualizaciones |

### 📊 Diagramas Mermaid Disponibles

- **Arquitectura General**: Componentes del sistema
- **Flujo de Registro**: Cómo se registra un jugador
- **Flujo de Compra**: Proceso de compra de billetes
- **Flujo de Creación de Sorteo**: Cómo se crea un sorteo
- **Estructura de Contexts**: Relaciones entre módulos

---

## scripts/

### 📝 Propósito
Scripts de automatización y utilidades para desarrollo y despliegue

### 🗂️ Estructura

```
scripts/
├── README.md                # Documentación de scripts
├── setup.sh                 # Instalación inicial del proyecto
├── start.sh                 # Iniciar todas las aplicaciones
├── seed_data.exs            # Script de carga de datos iniciales
└── ...
```

### 📌 Scripts Principales

#### `setup.sh`
**Qué hace:**
- Instala dependencias (mix deps.get)
- Compila las aplicaciones
- Crea base de datos si es necesario
- Carga datos iniciales

#### `start.sh`
**Qué hace:**
- Inicia el servidor central
- Inicia el cliente admin
- Inicia el cliente jugador
- Configura puertos (default: 4000, 4001, 4002)

#### `seed_data.exs`
**Qué hace:**
- Crea sorteos de ejemplo
- Crea usuarios de prueba
- Carga datos iniciales en JSON
- Permite pruebas rápidas

---

## assets/

### 📝 Propósito
Almacenamiento de recursos compartidos de frontend (si aplica)

### 🗂️ Estructura

```
assets/
├── css/                 # Estilos compartidos
├── js/                  # Scripts compartidos
└── images/              # Imágenes comunes
```

**Qué se puede encontrar:**
- Stylesheets globales (si se usa Tailwind, Bootstrap, etc.)
- Librerías JavaScript compartidas
- Logos e íconos del proyecto
- Fuentes personalizadas

---

## 📊 Relación entre Módulos

```
┌─────────────────────────────────────────────────────────────┐
│                    shared_code/                             │
│  (Constantes, Errores, Utils, Esquemas Compartidos)        │
└────────────────┬──────────────┬──────────────┬──────────────┘
                 │              │              │
        ┌────────▼────┐  ┌──────▼─────┐  ┌──────▼─────┐
        │   server/   │  │ admin_client│ │player_client
        │   (Core)    │  │             │ │             
        └────────────┘  └─────────────┘ └─────────────┘
```

### Dependencias
- **admin_client** depende de → `server/` + `shared_code/`
- **player_client** depende de → `server/` + `shared_code/`
- **server/** depende de → `shared_code/`

---

## 🔄 Flujo de Datos General

```
Jugador/Admin
     ↓
player_client/ / admin_client/
     ↓
HTTP/WebSocket
     ↓
server/
   ├── Controllers (HTTP)
   ├── Channels (WebSocket)
   └── Contexts (Lógica de Negocio)
        ├── draws/ (Sorteos)
        ├── audit/ (Auditoría)
        └── notifications/ (Notificaciones)
     ↓
shared_code/ (Utilidades)
```

---

## 🚀 Próximos Pasos para Desarrollo

1. **Revisar** `docs/Structures/00_START_HERE.md`
2. **Leer** documentos de arquitectura
3. **Explorar** contextos específicos según tu tarea
4. **Consultar** `GUIA_DESARROLLO.md` para setup

---

## 📞 Notas Importantes

- Las aplicaciones usan **Elixir 1.17** y **Phoenix**
- La persistencia es mediante **archivos JSON** (no hay BD)
- Comunicación entre apps via **HTTP** y **WebSockets**
- Código reutilizable en **shared_code/** para evitar duplicación
- Tests unitarios en cada carpeta `test/`

---

**Última actualización**: 26 de abril de 2026
