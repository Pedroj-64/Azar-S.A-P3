# Documentación - Azar S.A

## ¡COMIENZA AQUÍ!

**Nuevo en el proyecto?** Mira esto primero:

1. [DIAGNOSTICO.md](DIAGNOSTICO.md) - Estado actual del código
2. [PLAN_ACCION.md](PLAN_ACCION.md) - Cómo arreglarlo (checklist)
3. [ESTRUCTURA_CARPETAS.md](ESTRUCTURA_CARPETAS.md) - Dónde está cada cosa
4. [PATRON_CONTEXTS.md](PATRON_CONTEXTS.md) - Cómo está organizado
5. [GUIA_PLAYER_CLIENT_CONTEXTS.md](GUIA_PLAYER_CLIENT_CONTEXTS.md) - Cómo usar (con ejemplos)
6. [REFERENCIA_CONTEXTS.md](REFERENCIA_CONTEXTS.md) - Referencia rápida

---

## Estado de Documentación

| Documento | Estado | Propósito |
|-----------|--------|----------|
| DIAGNOSTICO.md | NUEVO | Estado actual: 10 problemas, soluciones, checklist |
| PLAN_ACCION.md | NUEVO | 3 fases de reparación, checklist, 20-24h estimadas |
| README.md | Actualizado | Índice maestro |
| ESTRUCTURA_CARPETAS.md | NUEVO | Mapeo completo del proyecto |
| PATRON_CONTEXTS.md | NUEVO | Patrón arquitectónico estándar |
| GUIA_PLAYER_CLIENT_CONTEXTS.md | NUEVO | Guía práctica con ejemplos |
| REFERENCIA_CONTEXTS.md | NUEVO + Consolidado | Referencia rápida + Migración |
| INTEGRACION_CONTROLLERS.md | NUEVO | Controllers player_client (3 files) |
| SERVER_CONTROLLERS.md | NUEVO | Controllers server (4 files) |
| ARQUITECTURA.md | Vigente | Arquitectura del sistema |
| REQUISITOS.md | Vigente | Especificaciones funcionales |
| GUIA_DESARROLLO.md | Vigente | Guía para desarrolladores |

**Total: 12 archivos bien estructurados (sin redundancias)**

---

## Documentación Arquitectónica

### ESTRUCTURA_CARPETAS.md
Mapeo completo del proyecto carpeta por carpeta:
- Estructura de directorios
- Propósito de cada carpeta
- Qué se encuentra en cada lugar
- Explicación detallada de contexts
- Relaciones entre módulos

### PATRON_CONTEXTS.md
Explicación del patrón de arquitectura estándar:
- Cómo se organizan los contexts
- Estructura: entity.ex, operations.ex, operations/, schemas/
- Por qué esta estructura
- Checklist para crear nuevos contexts
- Patrones y buenas prácticas

### GUIA_PLAYER_CLIENT_CONTEXTS.md
Guía práctica de uso con ejemplos reales:
- Cómo usar Purchases context
- Cómo usar Users context
- Ejemplos de código completos
- Integración en controllers
- Manejo de errores
- Casos de error comunes

### REFERENCIA_CONTEXTS.md
Referencia rápida visual:
- Diagramas de estructura
- Flujos de uso
- Matriz de decisión
- Snippets de código
- Checklist de validación
- Apéndice: Migración de código antiguo

### INTEGRACION_CONTROLLERS.md
Guía de integración de controllers en Phoenix:
- Controllers creados (UserController, PurchaseController, HealthController)
- Todos los endpoints disponibles con ejemplos curl
- Cómo integrar en router.ex
- Middleware de autenticación
- Ejemplos de testing

### SERVER_CONTROLLERS.md
Controllers del servidor central:
- 4 controllers (Health, Draw, Audit, Notification)
- 23 endpoints documentados
- Ejemplos con curl para cada endpoint
- Integración en router.ex
- Filtros avanzados y paginación

### ARQUITECTURA.md
Documentación de la arquitectura del sistema:
- Componentes principales
- Comunicación entre procesos
- Flujos de datos
- Estructura OTP (Supervisores, GenServers)
- Estados de sorteo
- Diagramas ASCII

### REQUISITOS.md
Especificación completa de requisitos:
- Requisitos funcionales (RF) por aplicación
- Requisitos no funcionales (RNF)
- Casos de uso principales (CU)
- Restricciones técnicas
- Tablas de especificación

### GUIA_DESARROLLO.md
Guía paso a paso para desarrolladores:
- Configuración inicial
- Instalación de dependencias
- Estructura de contextos
- Ejemplos de código
- Patterns y buenas prácticas
- Comandos útiles
- Prerrequisitos del sistema
- Instalación de Elixir
- Instalación de dependencias
- Configuración del entorno
- Troubleshooting

---

**Documentación completa del sistema**
