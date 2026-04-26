# Admin Client - Azar S.A

Aplicación Phoenix para que administradores gestionen sorteos, usuarios y reportes.

## Características

- Gestión de sorteos (crear, editar, ejecutar, cancelar)
- Reportes financieros y análisis
- Autenticación con 3 roles granulares
- Auditoría de operaciones

## Inicio Rápido

```bash
cd admin_client
mix deps.get
mix compile
mix phx.server
```

Aplicación disponible en `http://localhost:4000`

Ver [QUICKSTART.md](QUICKSTART.md) para ejemplos de uso.

## Estructura

```
lib/azar_admin/
├── contexts/
│   ├── users/          # Gestión de administradores
│   ├── draws/          # Gestión de sorteos
│   └── reports/        # Generación de reportes
│
└── controllers/
    ├── health_controller.ex
    ├── user_controller.ex
    ├── draw_controller.ex
    └── report_controller.ex

priv/data/
├── admin_users.json
├── draws.json
└── admin_reports.json
```

Total: 18+ endpoints HTTP, 21+ funciones operacionales.

## Documentación

- [QUICKSTART.md](QUICKSTART.md) - Guía de inicio rápido
- Ver carpeta `/docs` en raíz del proyecto para documentación detallada

## Contextos

### Users Context

Gestión de administradores con autenticación, roles y auditoría.

Roles: `super_admin`, `admin`, `analyst`

Operaciones:
- register_admin/1
- authenticate/2
- validate_session/2
- update_admin_role/3
- suspend_admin/2
- get_admin/1
- list_admins/0

### Draws Context

Gestión del ciclo de vida de sorteos.

Estados: `open`, `executed`, `cancelled`

Operaciones:
- create_draw/1
- update_draw/3
- execute_draw/3
- cancel_draw/2
- get_draw_statistics/1
- get_draw/1
- list_draws/0
- list_draws_by_status/1

### Reports Context

Generación de reportes financieros y análisis.

Tipos: `financial`, `draw_analysis`, `prize_summary`, `player_stats`

Operaciones:
- generate_financial_report/3
- generate_draw_analysis/2
- generate_prize_summary/3
- get_report/1
- list_reports/0
- list_reports_by_type/1

## Endpoints HTTP

Autenticación:
- POST `/admin/register`
- POST `/admin/authenticate`
- POST `/admin/validate-session`

Administradores:
- GET `/admin`
- GET `/admin/:id`
- PUT `/admin/:id/role`
- PUT `/admin/:id/suspend`

Sorteos:
- POST `/draws`
- PUT `/draws/:id`
- GET `/draws`
- GET `/draws/:id`
- GET `/draws/status/:status`
- POST `/draws/:id/execute`
- POST `/draws/:id/cancel`
- GET `/draws/:id/statistics`

Reportes:
- POST `/reports/financial`
- POST `/reports/draw-analysis`
- POST `/reports/prize-summary`
- GET `/reports`
- GET `/reports/:id`
- GET `/reports/type/:type`

Health:
- GET `/health`

## Seguridad

- Hash bcrypt para contraseñas
- Tokens de sesión
- Permisos granulares por rol
- Validación de entrada
- Auditoría de operaciones

## Persistencia

JSON con `AzarShared.JsonHelper`:
- `priv/data/admin_users.json`
- `priv/data/draws.json`
- `priv/data/admin_reports.json`

## Dependencias

- phoenix
- bcrypt_elixir
- jason
- plug_cowboy
- AzarShared (librería compartida)

Última actualización: 26 de abril de 2026
