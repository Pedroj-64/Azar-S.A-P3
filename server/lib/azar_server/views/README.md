# Server Views

Estructura minimalista de vistas para el servidor central Azar.

---

## Contenido

```
lib/azar_server/views/
├── components.ex              - Componentes reutilizables (alert, form, button, etc.)
├── draw_json.ex              - JSON view para API de sorteos
├── audit_json.ex             - JSON view para auditoría
├── notification_json.ex      - JSON view para notificaciones
├── report_json.ex            - JSON view para reportes
├── error_json.ex             - JSON view para errores
├── layout/
│   └── app.html.heex         - Layout base del dashboard
└── page/
    ├── dashboard.html.heex   - Dashboard con estadísticas
    ├── draws_list.html.heex  - Listado de sorteos
    ├── draws_form.html.heex  - Formulario crear/editar
    ├── reports.html.heex     - Reportes financieros
    └── audit.html.heex       - Logs de auditoría

priv/static/
├── css/app.css               - Estilos minimalistas
└── images/                   - Espacio para imágenes
```

---

## Características

- **Minimalista:** Sin frameworks frontend, solo CSS puro
- **Optimizado:** Tamaño de archivo bajo, carga rápida
- **Sin emojis:** Interfaz profesional y limpia
- **Responsive:** Funciona en desktop, tablet y móvil
- **Componentes:** Reutilizables y consistentes
- **Espacio para imágenes:** Áreas dedicadas para contenido visual

---

## Cómo Usar

### HTML en Controllers

```elixir
def index(conn, _params) do
  page_title = "Sorteos"
  render(conn, :index, page_title: page_title)
end
```

### JSON en Controllers

```elixir
def create(conn, %{"draw" => params}) do
  case DrawOps.create_draw(params) do
    {:ok, draw} -> json(conn, %{status: "ok", data: draw})
    {:error, reason} -> json(conn, %{status: "error", message: reason})
  end
end
```

### Componentes en Templates

```elixir
<.form_input label="Nombre" name="name" required={true} />
<.button text="Guardar" type="primary" />
<.badge badge_type="success" text="Activo" />
```

---

## Paleta de Colores

```
Primario:    #2c3e50 (Azul oscuro)
Secundario:  #34495e (Gris oscuro)
Acento:      #3498db (Azul claro)
Éxito:       #27ae60 (Verde)
Peligro:     #e74c3c (Rojo)
Advertencia: #f39c12 (Naranja)
Fondo:       #f5f6fa (Gris muy claro)
Superficie:  #ffffff (Blanco)
```

---

## Estructura de Layout

```
┌─────────────────────────────────────────┐
│ Topbar (título + user menu)             │
├──────┬──────────────────────────────────┤
│      │                                  │
│ Side │ Content Area                     │
│ bar  │                                  │
│      │ - Cards                          │
│      │ - Tablas                         │
│      │ - Formularios                    │
│      │ - Estadísticas                   │
└──────┴──────────────────────────────────┘
```

---

## Espacios para Imágenes

Cada página contiene áreas `.image-placeholder` donde se pueden:

1. **Sorteos:** Portada o banner del sorteo
2. **Reportes:** Gráficos financieros
3. **Dashboard:** Ilustraciones o gráficos
4. **Auditoría:** Gráficos de actividad

Dimensiones sugeridas:
- Cards: 300x200px
- Full-width: 800x400px
- Reports: 1000x600px

---

## Responsive Breakpoints

- **Desktop:** >= 1024px - Layout óptimo
- **Tablet:** 768px - 1023px - Compacto
- **Mobile:** < 768px - Full-width

---

## Validación de Formularios

Las clases de formulario incluyen:

- `:focus` - Highlight azul
- `:required` - Validación HTML5
- Mensajes de error en badge rojo

Ejemplo:
```html
<input type="email" class="form-input" required>
```

---

## Tablas

Características:
- Scroll horizontal en móvil
- Hover en filas
- Bordas limpias
- Espaciado consistente

---

## Responsabilidades

| Archivo | Función |
|---------|---------|
| `components.ex` | Componentes reutilizables |
| `*_json.ex` | Formateo de respuestas JSON |
| `layout/app.html.heex` | Estructura base HTML |
| `page/*.html.heex` | Páginas específicas |
| `css/app.css` | Estilos y variables |

---

## Próximos Pasos

1. Integración con Phoenix LiveView (si se necesita real-time)
2. Agregar librería de gráficos (Chart.js)
3. Subida de imágenes con preview
4. Temas oscuro/claro
5. Internacionalización (i18n)

---

**Minimalismo:** Lo necesario, nada más  
**Optimización:** Rápido y ligero  
**Consistencia:** Componentes reutilizables
