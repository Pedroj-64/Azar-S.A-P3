# Views - Estructura y Guía

**Fecha:** 28 de abril de 2026

---

## Overview

La estructura de views del servidor está organizada de manera minimalista, separando:

- **HTML Views** - Dashboards de administración
- **JSON Views** - Respuestas API estructuradas
- **Components** - Elementos reutilizables
- **CSS** - Estilos minimalistas y optimizados

---

## Estructura de Carpetas

```
server/lib/azar_server/views/
├── components.ex              (Componentes reutilizables)
├── error_json.ex              (Error JSON responses)
├── draw_json.ex               (Draw API responses)
├── audit_json.ex              (Audit API responses)
├── notification_json.ex       (Notification API responses)
├── report_json.ex             (Report API responses)
├── layout/
│   └── app.html.heex          (Layout base)
└── page/
    ├── dashboard.html.heex     (Dashboard principal)
    ├── draws_list.html.heex    (Listado de sorteos)
    ├── draws_form.html.heex    (Crear/editar sorteo)
    ├── reports.html.heex       (Reportes)
    └── audit.html.heex         (Auditoría)

priv/static/
├── css/
│   └── app.css                 (Estilos minimalista)
└── images/                     (Espacio para imágenes)
```

---

## HTML Views

### Layout Base (`app.html.heex`)

```html
- Sidebar con navegación
- Topbar con título de página
- Content area para contenido específico
- Sin complicaciones, minimalista
```

**Variables disponibles:**
- `@page_title` - Título de la página actual
- `@inner_content` - Contenido específico de la página

### Página Dashboard (`dashboard.html.heex`)

Muestra estadísticas rápidas:
- Sorteos activos
- Billetes vendidos
- Usuarios activos
- Ingresos totales

Incluye:
- Grid de stats
- Tabla de sorteos recientes
- Log de actividad

### Listado Sorteos (`draws_list.html.heex`)

Tabla con:
- Sorteos existentes
- Filtros por estado y fecha
- Botón para crear nuevo
- Acciones (Ver, Editar)

### Crear/Editar Sorteo (`draws_form.html.heex`)

Formulario completo con:
- Nombre y descripción
- Fecha del sorteo
- Precio y cantidad de billetes
- Fracciones disponibles
- Agregación de premios
- Espacio para imagen

### Reportes (`reports.html.heex`)

Sección financiera con:
- Resumen de totales
- Filtros por período
- Tabla de ingresos por sorteo
- Espacio para gráficos

### Auditoría (`audit.html.heex`)

Tabla de registros con:
- Fecha y hora
- Usuario y rol
- Tipo de acción
- Descripción
- IP de origen
- Estado (success/failed)

---

## JSON Views

### Patrón General

Todas las JSON views siguen el patrón:

```elixir
def action(%{data: data}) do
  %{
    status: "ok",
    data: format_data(data)
  }
end
```

### DrawJSON

```json
{
  "status": "ok",
  "data": {
    "id": "draw-001",
    "name": "Sorteo Especial",
    "status": "active",
    "draw_date": "2026-05-15T20:00:00Z",
    "total_tickets": 1000,
    "ticket_price": 10.00,
    "prizes_count": 3
  }
}
```

### AuditJSON

```json
{
  "status": "ok",
  "data": {
    "id": "audit-001",
    "action": "create",
    "entity_type": "draw",
    "user_name": "admin",
    "description": "Creó sorteo: ...",
    "timestamp": "2026-04-28T15:30:45Z"
  }
}
```

### NotificationJSON

```json
{
  "status": "ok",
  "data": {
    "id": "notif-001",
    "notification_type": "draw_result",
    "title": "Resultados disponibles",
    "read": false,
    "created_at": "2026-04-28T20:00:00Z"
  }
}
```

### ReportJSON

```json
{
  "status": "ok",
  "data": {
    "id": "report-001",
    "report_type": "financial_summary",
    "period_start": "2026-04-01T00:00:00Z",
    "total_income": 125450.00,
    "net_margin": 44880.00
  }
}
```

### ErrorJSON

```json
{
  "status": "error",
  "code": 404,
  "message": "Resource not found"
}
```

---

## CSS - Estructura Minimalista

### Variables de Diseño

```css
--color-primary: #2c3e50       (Azul oscuro)
--color-secondary: #34495e     (Gris oscuro)
--color-accent: #3498db        (Azul claro)
--color-success: #27ae60       (Verde)
--color-danger: #e74c3c        (Rojo)
--color-warning: #f39c12       (Naranja)
--color-bg: #f5f6fa            (Fondo)
--color-surface: #ffffff       (Superficie)
```

### Clases Disponibles

**Layout:**
- `.container` - Contenedor principal
- `.sidebar` - Barra lateral
- `.main-content` - Contenido principal
- `.topbar` - Barra superior

**Cards:**
- `.card` - Tarjeta base
- `.card-title` - Título
- `.card-subtitle` - Subtítulo
- `.stat-box` - Caja de estadística

**Grid:**
- `.grid-2` - 2 columnas
- `.grid-3` - 3 columnas
- `.grid-4` - 4 columnas

**Botones:**
- `.btn-primary` - Principal
- `.btn-success` - Éxito
- `.btn-danger` - Peligro
- `.btn-secondary` - Secundario

**Tablas:**
- `.table` - Tabla base
- `th` - Encabezado
- `td` - Celda

**Formularios:**
- `.form-group` - Grupo de formulario
- `.form-label` - Etiqueta
- `.form-input` - Input
- `.form-select` - Select
- `.form-textarea` - Textarea

**Badges:**
- `.badge-primary`
- `.badge-success`
- `.badge-danger`
- `.badge-warning`

**Alertas:**
- `.alert-info`
- `.alert-success`
- `.alert-danger`
- `.alert-warning`

---

## Componentes Reutilizables

Ubicación: `server/lib/azar_server/views/components.ex`

### Uso en Templates

```elixir
<.alert status="success" message="Sorteo creado exitosamente" />

<.stat_box value="42" label="Sorteos Activos" />

<.form_input label="Nombre" name="name" type="text" />

<.form_select label="Estado" name="status" 
  options={[{"Activo", "active"}, {"Pendiente", "pending"}]} />

<.badge badge_type="success" text="Activo" />

<.button text="Guardar" type="primary" href="/draws" />
```

---

## Espacios para Imágenes

### Placeholder

Dentro de cualquier template, usar:

```html
<div class="image-placeholder">
  Espacio para imagen (500x300px)
</div>
```

Esto crea un área con borde punteado donde se pueden:
- Subir imágenes
- Mostrar preview
- Colocar gráficos

### Ubicación de Imágenes

```
priv/static/images/
├── sorteos/         (Imágenes de sorteos)
├── logos/           (Logos)
├── icons/           (Iconos)
└── backgrounds/     (Fondos)
```

---

## Responsive Design

El CSS es 100% responsive:

- **Desktop:** Sidebar fijo, contenido flexible
- **Tablet:** Sidebar colapsable
- **Mobile:** Sidebar horizontal (flex)

Breakpoint principal: `768px`

---

## Estructura de Datos en Controllers

### HTML Response

```elixir
def index(conn, _params) do
  draws = DrawOps.list_draws()
  render(conn, :index, draws: draws, page_title: "Sorteos")
end
```

### JSON Response

```elixir
def create(conn, %{"draw" => params}) do
  case DrawOps.create_draw(params) do
    {:ok, draw} ->
      render(conn, :create, draw: draw)
    {:error, reason} ->
      conn
      |> put_status(:bad_request)
      |> render(:error, message: reason)
  end
end
```

---

## Mejores Prácticas

1. **Minimalismo:** Solo lo necesario, sin decoraciones
2. **Consistencia:** Usar componentes reutilizables
3. **Performance:** CSS minimal, sin frameworks externos
4. **Accesibilidad:** Semántica HTML correcta
5. **Responsive:** Móvil-first en diseño
6. **Espacio:** Dejar área para imágenes y gráficos
7. **Sin emojis:** Usar iconos con letras o símbolos

---

## Próximos Pasos

1. Conectar views con controllers en router
2. Agregar validaciones en formularios
3. Implementar subida de imágenes
4. Agregar gráficos (Chart.js)
5. Crear componentes para tablas dinámicas

---

**Versión:** 1.0  
**Última actualización:** 28/04/2026
