# Organización Visual - Centralizada en assets/

**IMPORTANTE:** Todos los archivos visuales (CSS, JS, locales) están centralizados en UNA sola carpeta.

## ✏️ DONDE EDITAS (Desarrollo)

```
server/assets/                      ← AQUI EDITAS TODO
├── css/
│   └── app.css                     ← Edita AQUI (560 líneas)
├── js/
│   └── i18n-theme.js               ← Edita AQUI (clase I18nManager)
├── locales/
│   ├── es.json                     ← Edita AQUI (traducciones español)
│   └── en.json                     ← Edita AQUI (traducciones inglés)
└── images/
    └── (imágenes del admin)
```

## 📦 DONDE SE SIRVEN (Producción)

```
server/priv/static/                 ← SE GENERA AUTOMATICAMENTE
├── css/
│   └── app.css                     ← Generado desde assets/css/
├── js/
│   └── i18n-theme.js               ← Generado desde assets/js/
├── locales/
│   ├── es.json                     ← Generado desde assets/locales/
│   └── en.json
└── images/
```

## 🔄 Flujo

### Desarrollo (Ahora)

1. **Editas:** `server/assets/css/app.css`
2. **Ejecutas:** `./setup.sh` (una sola vez)
   - Copia de `assets/` → `priv/static/`
3. **Servidor sirve:** `priv/static/css/app.css` (a cliente)
4. **Cambios:** Edita en `assets/`, ejecuta `./setup.sh` de nuevo

### Producción (Con Build Tools - Futuro)

```bash
npm run build
# Automáticamente copia de assets/ → priv/static/
mix phx.digest
# Minifica y compila assets finales
```

## ✅ Checklist

- [x] TODO lo visual en `assets/` (no en `priv/static/`)
- [x] `priv/static/` vacío (solo con .gitkeep)
- [x] `setup.sh` para copiar en desarrollo
- [x] Endpoint sirve desde `priv/static/` (después del setup)
- [x] Sin duplicación de archivos
- [x] Organización clara y centralizada

## 📝 Pasos para Desarrollar

```bash
# Primer setup
cd server
./setup.sh

# Editar archivos
# Archivo: server/assets/css/app.css
# - Cambias color, spacing, fonts, etc.
# - Guardas

# Si cambiaste assets, copia nuevamente:
./setup.sh

# Inicia servidor
mix phx.server
```

## 🚨 NUNCA

- ❌ Edites `priv/static/css/app.css` directamente (se sobreescribe)
- ❌ Pongas archivos en `priv/static/` - van en `assets/`
- ❌ Duplicues CSS o JS en múltiples lugares

## 📂 Estructura Total

```
server/
├── assets/                  ← UNICO LUGAR = Desarrollo
│   ├── css/
│   ├── js/
│   ├── locales/
│   └── images/
├── priv/static/             ← AUTO = Producción
│   ├── css/
│   ├── js/
│   ├── locales/
│   └── images/
└── setup.sh                 ← Script para copiar

FLUJO: assets/ → setup.sh → priv/static/ → Cliente
```

---

**Resumen:** Edita en `assets/`, ejecuta `./setup.sh`, y todo se copia a `priv/static/` automáticamente. **Centralizado, limpio, sin duplicación.**
