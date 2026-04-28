# Server Documentation

Documentación específica del servidor central (panel de administración).

## 📚 Guías Principales

- [**VISUAL_ORGANIZATION.md**](./VISUAL_ORGANIZATION.md) - ⭐ EMPEZAR AQUI
  - Cómo están organizados CSS, JS e idiomas
  - Dónde editar archivos visuales
  - Flujo de desarrollo

- [**ASSETS_STRUCTURE.md**](./ASSETS_STRUCTURE.md) - Monorepo
  - Estructura de assets para monorepo con 3 apps
  - Configuración de Plug.Static
  - Próximos pasos con build tools

- [**I18N_THEME_GUIDE.md**](./I18N_THEME_GUIDE.md) - Internacionalización
  - Cambiar entre Español e Inglés
  - Tema oscuro/claro
  - Cómo agregar nuevas traducciones

- [**VIEWS_GUIDE.md**](./VIEWS_GUIDE.md) - Vistas HEEx
  - Guía de templates y componentes
  - Estructura de vistas

- [**VIEWS_SUMMARY.md**](./VIEWS_SUMMARY.md) - Resumen técnico
  - Lista de todas las vistas creadas
  - Campos y estructura de cada página

## 🚀 Quick Start

```bash
cd server

# Primer setup
./setup.sh

# Instalar dependencias y crear datos
mix setup

# Iniciar servidor
mix phx.server

# Acceder
# http://localhost:4000
```

## 📂 Estructura

```
server/
├── docs/
│   ├── README.md (estás aquí)
│   ├── VISUAL_ORGANIZATION.md ⭐
│   ├── ASSETS_STRUCTURE.md
│   ├── I18N_THEME_GUIDE.md
│   ├── VIEWS_GUIDE.md
│   └── VIEWS_SUMMARY.md
├── assets/                  ← EDITA AQUI (CSS, JS, idiomas)
├── lib/azar_server/
├── priv/
│   ├── data/               ← Datos JSON
│   └── static/             ← AUTO (después de setup.sh)
└── setup.sh                ← EJECUTA UNA VEZ
```

## ❗ Punto Clave

**EDITA ARCHIVOS EN:** `assets/` (CSS, JS, locales)  
**SE SIRVEN DESDE:** `priv/static/` (automático con `setup.sh`)

Ver [VISUAL_ORGANIZATION.md](./VISUAL_ORGANIZATION.md) para más detalles.
