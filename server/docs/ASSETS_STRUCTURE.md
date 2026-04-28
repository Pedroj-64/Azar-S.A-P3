# Estructura de Archivos - Assets vs priv/static (Monorepo)

**Última actualización:** 28 de abril de 2026

---

## Estructura Correcta - Monorepo con Múltiples Apps

En un proyecto con **server, admin_client y player_client**, CADA APP tiene su propio `assets/`:

```
Azar S.A P3/
├── server/
│   ├── assets/                  ← Assets DEL SERVER
│   │   ├── css/app.css
│   │   ├── js/i18n-theme.js
│   │   ├── locales/
│   │   │   ├── es.json
│   │   │   └── en.json
│   │   └── images/
│   ├── lib/azar_server/
│   │   └── views/               ← Templates HEEx del server
│   │       ├── layout/app.html.heex
│   │       ├── page/
│   │       └── ...
│   └── priv/static/             ← Compilado (sincronizado desde assets/)
│       ├── css/app.css
│       ├── js/i18n-theme.js
│       ├── locales/*.json
│       └── ...
│
├── admin_client/
│   ├── assets/                  ← Assets DEL ADMIN (similar)
│   ├── lib/azar_admin/
│   │   └── views/
│   └── priv/static/             ← Compilado desde assets/ de admin
│
├── player_client/
│   ├── assets/                  ← Assets DEL PLAYER (similar)
│   ├── lib/azar_player/
│   │   └── views/
│   └── priv/static/             ← Compilado desde assets/ de player
│
└── shared_code/                 ← Código Elixir compartido (SIN assets)
    └── lib/azar_shared/
        └── (módulos, contextos, utilidades)
```

---

## ¿Por Qué NO Un `assets/` Centralizado?

❌ **INCORRECTO (Lo que teníamos):**

```
Azar S.A P3/
├── assets/                 ← Intenta servir a TODOS
│   ├── css/
│   ├── js/
│   └── locales/
├── server/priv/static/     ← Confusión: ¿De dónde vienen?
├── admin_client/priv/static/
└── player_client/priv/static/
```

**Problemas:**
- ¿Qué CSS usa el server? ¿Y el admin? ¿Son iguales?
- ¿Las traducciones son compartidas o diferentes?
- Si cambias algo en assets, ¿afecta a todos?
- No puedes deployar solo la app de jugador

✅ **CORRECTO (Lo que tenemos ahora):**

```
Azar S.A P3/
├── server/assets/          ← Claramente para SERVER
│   ├── css/
│   ├── js/
│   └── locales/
├── admin_client/assets/    ← Claramente para ADMIN
├── player_client/assets/   ← Claramente para PLAYER
```

**Ventajas:**
- Cada app es independiente
- CSS, JS, traducciones específicas de cada app
- Deploy selectivo (solo lo que cambió)
- Escalable (agregar más apps es fácil)

---

## Flujo de Carga - Cómo Carga Cada App

### Server (Ejemplo)

```
1. Navegador: GET /              (en puerto 4000)
   ↓
2. Phoenix (azar_server):
   - Renderiza: lib/azar_server/views/layout/app.html.heex
   - Referencias: <script src="/js/i18n-theme.js">
   ↓
3. Descarga estáticos desde priv/static/:
   - GET /css/app.css
   - GET /js/i18n-theme.js
   - GET /locales/es.json
   ↓
4. JavaScript ejecuta:
   - I18nManager carga traducciones
   - localStorage: language='es', theme='light'
   ↓
5. UI lista con idioma y tema correcto
```

### Admin Client (Similar, Port 4001)

```
1. Navegador: GET /              (en puerto 4001)
   ↓
2. Phoenix (azar_admin):
   - Renderiza: lib/azar_admin/views/layout/app.html.heex
   - Referencias: <script src="/js/i18n-theme.js">
   ↓
3. Descarga estáticos desde priv/static/:
   - (Puede ser DIFERENTE del server)
   - GET /css/app.css          ← CSS DEL ADMIN
   - GET /js/i18n-theme.js
   - GET /locales/es.json      ← Traducciones del ADMIN
```

---

## Localización de Archivos

### Archivos FUENTE (Development)

```
server/assets/
├── css/app.css              ← Edita aquí para server
├── js/i18n-theme.js
└── locales/
    ├── es.json              ← Traducciones españolas del server
    └── en.json              ← Traducciones inglesas del server
```

### Archivos COMPILADOS (Production)

```
server/priv/static/
├── css/app.css              ← Compilado desde server/assets/css/
├── js/i18n-theme.js         ← Compilado desde server/assets/js/
└── locales/
    ├── es.json              ← Copiado desde server/assets/locales/
    └── en.json
```

---

## Endpoint Configuration

Cada app tiene su propia configuración de qué archivos servir.

### `server/lib/azar_server/endpoint.ex`

```elixir
plug Plug.Static,
  at: "/",
  from: :azar_server,                    ← Sirve archivos del server
  gzip: false,
  only: ~w(css fonts images js locales favicon.ico robots.txt)
```

### `admin_client/lib/azar_admin/endpoint.ex`

```elixir
plug Plug.Static,
  at: "/",
  from: :azar_admin,                     ← Sirve archivos del admin
  gzip: false,
  only: ~w(css fonts images js locales favicon.ico robots.txt)
```

Cada app sirve sus PROPIOS archivos desde `priv/static/`.

---

## Datos Persistentes (JSON)

Los datos (draws.json, users.json, etc.) van en `priv/data/`:

```
server/
├── priv/
│   ├── data/                ← Datos persistentes
│   │   ├── draws.json
│   │   ├── purchases.json
│   │   ├── users.json
│   │   ├── admin_users.json
│   │   ├── audit_logs.json
│   │   └── notifications.json
│   │
│   └── static/              ← Assets compilados
│       ├── css/
│       ├── js/
│       └── locales/
```

**NOTA:** `priv/data/` es diferente de `priv/static/`:
- `priv/data/` - Datos del negocio (persisten)
- `priv/static/` - Assets web (se sirven al cliente)

---

## Checklist de Organización

- [x] `server/assets/` contiene archivos FUENTE
- [x] `server/priv/static/` contiene archivos COMPILADOS
- [x] `admin_client/assets/` listo para archivos
- [x] `player_client/assets/` listo para archivos
- [x] Cada app tiene su Plug.Static independiente
- [x] Endpoint actualizado con "locales"
- [x] Templates HEEx viven EN LA APP (lib/*/views/)
- [x] No hay `assets/` centralizado en la raíz
- [x] Cada app es completamente independiente

---

## Próximos Pasos

### Para Admin Client

1. Copiar o crear: `admin_client/assets/css/app.css`
2. Copiar o crear: `admin_client/assets/js/i18n-theme.js`
3. Copiar o crear: `admin_client/assets/locales/{es,en}.json`
4. Crear templates en: `admin_client/lib/azar_admin/views/`
5. Build: Sincronizar con `admin_client/priv/static/`

### Para Player Client

1. Copiar o crear: `player_client/assets/css/app.css`
2. Copiar o crear: `player_client/assets/js/i18n-theme.js`
3. Copiar o crear: `player_client/assets/locales/{es,en}.json`
4. Crear templates en: `player_client/lib/azar_player/views/`
5. Build: Sincronizar con `player_client/priv/static/`

### Cuando Agregues Build Tools

```bash
# Opción A: Build por app
cd server && npm run build         # Compila server/assets → server/priv/static
cd admin_client && npm run build   # Compila admin/assets → admin/priv/static
cd player_client && npm run build  # Compila player/assets → player/priv/static

# Opción B: Build monorepo (con script raíz)
npm run build:all                  # Compila todas las apps
```

---

## Ejemplo: ¿Qué Sucede Si Cambio CSS?

### Escenario 1: Cambio CSS del Server

```
Editas: server/assets/css/app.css
  ↓ (con build tools)
Compila a: server/priv/static/css/app.css
  ↓
Server lo sirve en GET /css/app.css
  ↓
Cliente actualiza (reload page)
  ↓
Admin Client: ❌ NO AFECTADO (tiene su propio CSS)
Player Client: ❌ NO AFECTADO (tiene su propio CSS)
```

### Escenario 2: Cambio i18n del Admin

```
Editas: admin_client/assets/locales/es.json
  ↓ (sin build tools, copia manual o sync)
Actualiza: admin_client/priv/static/locales/es.json
  ↓
Admin lo sirve en GET /locales/es.json
  ↓
JavaScript carga traducciones nuevas
  ↓
Server: ❌ NO AFECTADO (tiene sus locales)
Player: ❌ NO AFECTADO (tiene sus locales)
```

---

## Información que Carga Cada App

### Server (al iniciar)

```
Configuration (config/config.exs)
├── Endpoint: localhost:4000
├── Static path: priv/static/
└── Data path: priv/data/

Modules (lib/azar_server/)
├── Contexts: Draws, Audit, Notifications...
├── Controllers: DrawController, AuditController...
├── Views: app.html.heex, dashboard.html.heex...
└── Components: alert, stat_box, button...

Assets (server/priv/static/)
├── css/app.css (560 líneas)
├── js/i18n-theme.js
└── locales/es.json, en.json

Data (server/priv/data/)
└── draws.json, users.json, purchases.json...
```

### Admin Client (similar, puerto 4001)

```
Configuration (admin_client/config/config.exs)
├── Endpoint: localhost:4001
├── Static path: priv/static/
└── (Puede diferir del server)
...
```

---

## Resumen Rápido

| Ubicación | Propósito | Editar | Serve al Cliente |
|-----------|-----------|--------|------------------|
| `server/assets/` | Código fuente del server | ✓ Sí | ✗ No |
| `server/priv/static/` | Assets compilados del server | ✗ No (genera) | ✓ Sí |
| `admin_client/assets/` | Código fuente del admin | ✓ Sí | ✗ No |
| `admin_client/priv/static/` | Assets compilados del admin | ✗ No (genera) | ✓ Sí |
| `lib/*/views/` | Templates HEEx (EN LA APP) | ✓ Sí | Renderizado |
| `shared_code/` | Código Elixir compartido | ✓ Sí (modules) | ✗ No |
| `priv/data/` | Datos persistentes (JSON) | ✓ Sí | ✗ No |

---

**Conclusión:** Cada app es **completamente independiente**. Server no usa assets de admin, ni admin usa assets de player. Esto permite:
- Deploy selectivo
- Cambios sin impacto cruzado
- Escalabilidad
- Mantenibilidad

---

**Versión:** 2.0 (Corregida para Monorepo)  
**Última actualización:** 28/04/2026  
**Próximo:** Agregar build tools o crear assets para admin/player


---

## Archivo Endpoint (Configuración)

`lib/azar_server/endpoint.ex` - Configuración de qué archivos se sirven:

```elixir
plug Plug.Static,
  at: "/",
  from: :azar_server,
  gzip: false,
  only: ~w(css fonts images js locales favicon.ico robots.txt)
```

**`only:` lista EXACTAMENTE qué directorios se sirven como públicos:**
- ✓ `css/` - Se sirve
- ✓ `js/` - Se sirve
- ✓ `locales/` - Se sirve (agregado recientemente)
- ✗ Cualquier otra carpeta NO se sirve

---

## Ejemplo Real: Carga de i18n

### 1. Cliente solicita la app

```
GET / → Phoenix devuelve layout/app.html.heex
```

### 2. Layout incluye script

```heex
<!-- En lib/azar_server/views/layout/app.html.heex -->
<script defer src={~p"/js/i18n-theme.js"}></script>
```

Phoenix convierte `~p"/js/i18n-theme.js"` a:

```html
<script defer src="/js/i18n-theme.js"></script>
```

### 3. Navegador descarga

```
GET /js/i18n-theme.js → 200 OK
(Served from priv/static/js/i18n-theme.js)
```

### 4. Script ejecuta en DOM

```javascript
document.addEventListener('DOMContentLoaded', () => {
  window.i18nManager = new I18nManager();
});
```

### 5. I18nManager carga locales

```javascript
const enResponse = await fetch('/locales/en.json');
//   ↓
// GET /locales/en.json → 200 OK
// (Served from priv/static/locales/en.json)
```

### 6. Traducción completada

```html
<!-- Before -->
<span data-i18n="nav.draws">Sorteos</span>

<!-- After (JavaScript) -->
<span data-i18n="nav.draws">Draws</span>  <!-- si lang='en' -->
<!-- o -->
<span data-i18n="nav.draws">Sorteos</span>  <!-- si lang='es' -->
```

---

## Archivo de Configuración

### `config/config.exs`

```elixir
# Ubicación de datos persistentes (JSON)
config :azar_server,
  json_data_path: "priv/data",
  audit_log_path: "priv/data/audit_logs.json",
  notifications_path: "priv/data/notifications.json"
```

**`priv/` estructura:**

```
priv/
├── data/                  (Datos persistentes JSON)
│   ├── draws.json
│   ├── purchases.json
│   ├── users.json
│   ├── admin_users.json
│   ├── audit_logs.json
│   ├── admin_reports.json
│   └── notifications.json
│
└── static/               (Archivos públicos compilados)
    ├── css/
    ├── js/
    ├── locales/
    ├── images/
    └── (otros)
```

---

## Checklist de Organización

- [x] `assets/` contiene archivos FUENTE (desarrollo)
- [x] `priv/static/` contiene archivos COMPILADOS (producción)
- [x] `Plug.Static` configurado para servir: css, js, locales, images
- [x] Endpoint actualizado (`locales` agregado a la lista)
- [x] CSS y JS duplicados en ambas carpetas
- [x] JSON locales duplicados en ambas carpetas
- [x] Layout carga archivos desde `priv/static/` (vía `~p` helper)

---

## Próximos Pasos (Futuro)

### Opción A: Mantener Simple (Actual)

- Editar archivos en `assets/`
- Copiar manualmente a `priv/static/`
- Sin herramientas de build
- Ideal para equipos pequeños

### Opción B: Agregar Build Tools (Recomendado)

- Instalar Esbuild / Webpack
- Agregar scripts en `package.json`
- `npm run build` → compila `assets/` → `priv/static/`
- Production: minificación automática
- Ideal para escalabilidad

**Build script ejemplo (futuro):**

```json
{
  "scripts": {
    "build": "esbuild assets/js/*.js --bundle --minify --outdir=priv/static/js",
    "watch": "esbuild assets/js/*.js --bundle --watch --outdir=priv/static/js"
  }
}
```

---

## Información que Carga la App

### Al iniciar Phoenix

1. **Configuración** (config/config.exs)
   - Endpoint URL
   - Rutas de datos JSON
   - Variables de entorno

2. **Dependencias** (deps/)
   - Phoenix framework
   - Plug para servir estáticos
   - Otras librerías

3. **Módulos Elixir** (lib/)
   - Contextos (Draws, Audit, Notifications, etc.)
   - Controladores (Controllers)
   - Vistas (Views)

### Al cargar página en navegador

1. **HTML** (renderizado por HEEx)
   - Layout con navbar, sidebar
   - Contenido dinámico (Dashboard, Draws, etc.)
   - Scripts y estilos

2. **CSS** (desde `priv/static/css/app.css`)
   - Variables CSS (luz/oscuro)
   - Estilos de componentes
   - Responsive design

3. **JavaScript** (desde `priv/static/js/`)
   - `app.js` - Funcionalidad principal
   - `i18n-theme.js` - Traducciones y tema

4. **Datos** (desde `priv/static/locales/`)
   - `es.json` - Traducciones españolas
   - `en.json` - Traducciones inglesas

5. **localStorage** (navegador)
   - `language` - Idioma activo (es/en)
   - `theme` - Tema activo (light/dark)

---

## Resumen Rápido

| Aspecto | assets/ | priv/static/ |
|---------|---------|--------------|
| **Propósito** | Código FUENTE | Código COMPILADO |
| **Se sirve al cliente?** | ✗ No | ✓ Sí |
| **Donde editar** | Aquí | No (sincronizar con assets/) |
| **CSS** | Fuente SASS/CSS | CSS minificado |
| **JS** | Módulos ES6 | JS bundled |
| **Locales** | JSON original | JSON idéntico |
| **Build step?** | Sí (futuro) | Auto (de assets/) |

---

**Nota:** Actualmente todo se copia manualmente. Con build tools se automatiza.
