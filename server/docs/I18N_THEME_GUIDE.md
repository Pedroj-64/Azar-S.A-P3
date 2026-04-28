# i18n y Tema Oscuro/Claro

**Fecha:** 28 de abril de 2026

---

## Overview

El sistema incluye soporte completo para:

1. **Internacionalización (i18n):** Español (ES) e Inglés (EN)
2. **Tema:** Modo claro (light) y oscuro (dark)

Ambas configuraciones se guardan en `localStorage` y persisten entre sesiones.

---

## Estructura de Archivos

```
server/priv/static/
├── locales/
│   ├── es.json          (Traducciones españolas)
│   └── en.json          (Traducciones inglesas)
├── js/
│   └── i18n-theme.js    (Manager de i18n y tema)
└── css/
    └── app.css          (Variables CSS para temas)

lib/azar_server/views/
└── layout/app.html.heex (Layout actualizado con i18n)
```

---

## Archivos JSON de Traducciones

### Estructura

```json
{
  "common": {
    "app_name": "Azar Server",
    "language": "Idioma"
  },
  "nav": {
    "home": "Inicio",
    "draws": "Sorteos"
  },
  "dashboard": {
    "active_draws": "Sorteos Activos"
  }
}
```

### Localización de Traducciones

- `es.json` - Español (predeterminado)
- `en.json` - Inglés

Ambos archivos están en: `/server/priv/static/locales/`

---

## Sistema de i18n

### Clase: I18nManager

Ubicación: `server/priv/static/js/i18n-theme.js`

**Métodos disponibles:**

```javascript
// Cambiar idioma
i18nManager.setLanguage('en');  // English
i18nManager.setLanguage('es');  // Español

// Cambiar tema
i18nManager.setTheme('dark');   // Tema oscuro
i18nManager.setTheme('light');  // Tema claro

// Alternar tema
i18nManager.toggleTheme();

// Obtener traducción
const translation = i18nManager.getTranslation('nav.draws');
```

### LocalStorage

Se guarda automáticamente:

```javascript
localStorage.getItem('language');  // 'en' o 'es'
localStorage.getItem('theme');     // 'light' o 'dark'
```

---

## Usar i18n en Templates

### Atributo data-i18n

```heex
<!-- Traducción de texto -->
<span data-i18n="nav.draws">Sorteos</span>

<!-- Traducción de placeholder -->
<input type="text" data-i18n-placeholder="draws.search" placeholder="Buscar...">

<!-- Con estilos -->
<h1 class="title" data-i18n="dashboard.title">Dashboard</h1>
```

### Estructura de Claves

```
common.app_name
nav.draws
dashboard.active_draws
draws.create
reports.financial
audit.logs
buttons.save
messages.success
```

---

## Variables CSS para Tema

### Luz (Light - Default)

```css
--color-primary: #2c3e50       (Azul oscuro)
--color-bg: #f5f6fa            (Fondo gris claro)
--color-surface: #ffffff       (Blanco)
--color-text: #2c3e50          (Texto oscuro)
--color-border: #ddd           (Borde gris)
```

### Oscuridad (Dark)

```css
--color-primary: #1a252f       (Azul muy oscuro)
--color-bg: #0f1419            (Negro)
--color-surface: #1a1f26       (Gris muy oscuro)
--color-text: #e0e0e0          (Texto claro)
--color-border: #333           (Borde gris oscuro)
```

**Aplicar tema a HTML:**

```html
<!-- Light (default) -->
<html data-theme="light">

<!-- Dark -->
<html data-theme="dark">
```

---

## Controles de Usuario

### Ubicación

En la esquina inferior derecha (`.controls-bar`):

```
┌─────────────────┐
│ [Español ▼] [🌙] │
│ [English ▼] [☀️] │
└─────────────────┘
```

### Elementos

1. **Selector de Idioma** (`#language-select`)
   - Opciones: Español (es), English (en)
   - Cambio automático de interfaz

2. **Botón de Tema** (`#theme-toggle`)
   - Muestra 🌙 en modo light
   - Muestra ☀️ en modo dark
   - Toggle al hacer click

---

## Flujo de Carga

```
1. DOM Load → i18n-theme.js
   ↓
2. Constructor I18nManager
   ↓
3. loadTranslations() → fetch es.json + en.json
   ↓
4. applyTheme() → obtener tema de localStorage
   ↓
5. applyLanguage() → obtener idioma de localStorage
   ↓
6. setupListeners() → escuchar cambios
   ↓
7. Interfaz lista con idioma y tema correcto
```

---

## Ejemplo: Agregar Nueva Traducción

### 1. Agregar a es.json

```json
{
  "my_section": {
    "my_key": "Mi texto en español"
  }
}
```

### 2. Agregar a en.json

```json
{
  "my_section": {
    "my_key": "My text in English"
  }
}
```

### 3. Usar en Template

```heex
<span data-i18n="my_section.my_key">Texto por defecto</span>
```

### 4. Acceder desde JavaScript

```javascript
const text = i18nManager.getTranslation('my_section.my_key');
console.log(text);  // "Mi texto en español" o "My text in English"
```

---

## Almacenamiento Persistente

### Datos Guardados en localStorage

```javascript
localStorage.language = 'es'|'en'   // Idioma actual
localStorage.theme = 'light'|'dark' // Tema actual
```

### Persistencia Entre Sesiones

El usuario verá la misma preferencia cada vez que vuelva:

```
Sesión 1:
- Usuario cambia a Inglés
- localStorage.language = 'en'

Sesión 2:
- Usuario vuelve a visitar
- Automáticamente carga en Inglés
```

---

## Responsive en Controles

### Desktop
```
Controles en esquina inferior derecha
Horizontal: [Selector] [Botón]
```

### Tablet/Mobile
```
Controles en esquina inferior derecha
Vertical: [Selector]
         [Botón]
```

---

## Casos de Uso

### Cambiar Idioma en Runtime

```javascript
// Usuario hace click en selector
document.getElementById('language-select').addEventListener('change', (e) => {
  i18nManager.setLanguage(e.target.value);
});
```

### Cambiar Tema en Runtime

```javascript
// Usuario hace click en botón
document.getElementById('theme-toggle').addEventListener('click', () => {
  i18nManager.toggleTheme();
});
```

### Obtener Traducción en Script

```javascript
const label = i18nManager.getTranslation('buttons.save');
const button = document.createElement('button');
button.textContent = label;  // "Guardar" o "Save"
```

---

## Validación

### Idiomas Soportados

- `en` - English
- `es` - Español (predeterminado)

### Temas Soportados

- `light` - Tema claro (predeterminado)
- `dark` - Tema oscuro

Valores inválidos serán ignorados.

---

## Performance

- **Carga:** Ambas traducciones cargan una sola vez
- **Cambio:** Instantáneo (cambio de atributos HTML)
- **Storage:** localStorage es muy rápido
- **Sin servidor:** Todo en cliente (excepto fetch inicial)

---

## Extensiones Futuras

1. **Más idiomas:** Agregar pt.json, fr.json, etc.
2. **Más temas:** Auto (según preferencia del SO)
3. **Persistencia:** Guardar en base de datos del usuario
4. **Fallback:** Idioma por defecto si no existe clave

---

## Checklist

- [x] Archivos JSON de traducciones (es.json, en.json)
- [x] Clase I18nManager (i18n-theme.js)
- [x] Variables CSS para temas
- [x] Controles de usuario (selector + botón)
- [x] localStorage persistente
- [x] Layout actualizado con data-i18n
- [x] Responsive design
- [ ] Testing de todas las combinaciones de idioma/tema

---

**Versión:** 1.0  
**Última actualización:** 28/04/2026  
**Próximo:** Agregar más idiomas o personalización por usuario
