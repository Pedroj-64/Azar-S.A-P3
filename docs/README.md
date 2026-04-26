# Documentación - Azar S.A

Bienvenido a la documentación del proyecto Azar S.A. Este directorio contiene toda la información necesaria para entender, desarrollar y mantener el sistema.

---

## Estructura de Documentación

La documentación está organizada en las siguientes carpetas temáticas:

### 01-Inicio
**Punto de partida para nuevos desarrolladores y revisiones generales**

- **README.md** - Este archivo (índice general)
- **DIAGNOSTICO.md** - Estado actual del código: problemas identificados, soluciones propuestas
- **PLAN_ACCION.md** - Plan de 3 fases para reparaciones, checklist detallado

### 02-Arquitectura
**Documentación de diseño y estructura del sistema**

- **ARQUITECTURA.md** - Componentes principales, comunicación entre procesos, estructura OTP
- **ESTRUCTURA_CARPETAS.md** - Mapeo carpeta por carpeta del proyecto
- **PATRON_CONTEXTS.md** - Patrón arquitectónico estándar (entity.ex, operations.ex, schemas/)

### 03-Guias
**Guías prácticas de desarrollo y uso**

- **GUIA_DESARROLLO.md** - Configuración inicial, instalación, comandos útiles
- **GUIA_PLAYER_CLIENT_CONTEXTS.md** - Cómo usar los contexts (con ejemplos reales)
- **REFERENCIA_CONTEXTS.md** - Referencia rápida, diagramas, snippets de código

### 04-API
**Documentación de endpoints HTTP**

- **INTEGRACION_CONTROLLERS.md** - Controllers del player_client (15 endpoints, ejemplos curl)
- **SERVER_CONTROLLERS.md** - Controllers del server (23 endpoints, ejemplos curl)

### 05-Requisitos
**Especificaciones funcionales**

- **REQUISITOS.md** - Requisitos funcionales y no funcionales del sistema

### 06-Diagrams
**Diagramas y visualizaciones**

- **Structures/** - Diagramas Mermaid de la arquitectura y flujos

---

## Por Dónde Empezar

Depende de tu rol:

### Si eres nuevo en el proyecto
1. Lee [DIAGNOSTICO.md](01-Inicio/DIAGNOSTICO.md) para entender el estado actual
2. Luego [ARQUITECTURA.md](02-Arquitectura/ARQUITECTURA.md) para entender el diseño
3. Consulta [GUIA_DESARROLLO.md](03-Guias/GUIA_DESARROLLO.md) para configurar el ambiente

### Si necesitas arreglar algo
1. Abre [PLAN_ACCION.md](01-Inicio/PLAN_ACCION.md) para ver las tareas priorizadas
2. Consulta [PATRON_CONTEXTS.md](02-Arquitectura/PATRON_CONTEXTS.md) para entender la estructura
3. Usa [GUIA_PLAYER_CLIENT_CONTEXTS.md](03-Guias/GUIA_PLAYER_CLIENT_CONTEXTS.md) como referencia

### Si necesitas entender los endpoints
1. Abre [INTEGRACION_CONTROLLERS.md](04-API/INTEGRACION_CONTROLLERS.md) para player_client
2. O [SERVER_CONTROLLERS.md](04-API/SERVER_CONTROLLERS.md) para server

### Si necesitas ver diagramas
1. Explora [06-Diagrams/Structures/](06-Diagrams/Structures/)

---

## Mapa de Documentación Rápido

| Documento | Propósito | Audiencia |
|-----------|----------|-----------|
| DIAGNOSTICO.md | Estado actual | Todos |
| PLAN_ACCION.md | Tareas a hacer | Desarrolladores |
| ARQUITECTURA.md | Diseño del sistema | Arquitectos |
| ESTRUCTURA_CARPETAS.md | Mapeo del proyecto | Nuevos |
| PATRON_CONTEXTS.md | Cómo estructurar código | Desarrolladores |
| GUIA_DESARROLLO.md | Setup y comandos | Nuevos |
| GUIA_PLAYER_CLIENT_CONTEXTS.md | Ejemplos prácticos | Desarrolladores |
| REFERENCIA_CONTEXTS.md | Referencia rápida | Todos |
| INTEGRACION_CONTROLLERS.md | Endpoints player_client | API |
| SERVER_CONTROLLERS.md | Endpoints server | API |
| REQUISITOS.md | Especificaciones | Todos |
| Diagrams/ | Visualizaciones | Todos |

---

## Estado del Proyecto

**Última actualización:** 26 de abril de 2026

Ver [DIAGNOSTICO.md](01-Inicio/DIAGNOSTICO.md) para detalles actualizados.

---

## Contacto y Soporte

Para preguntas sobre la documentación o el proyecto, consulta con el equipo de desarrollo.
