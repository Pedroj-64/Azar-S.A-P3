# 05 Contexts - Detalles de Cada Contexto

## 📊 Diagramas en esta carpeta

Son **diagramas profundos** de cada carpeta contexts/

### 1️⃣ `01_draws.mmd`
**Qué es:** Detalles de `contexts/draws/`

**Muestra:**
- **draw.ex** → Struct del sorteo (nombre, fecha, billetes, estado)
- **schemas/ticket.ex** → Struct del billete (número, propietario, precio)
- **schemas/prize.ex** → Struct del premio (valor, números ganadores)
- **operations.ex** → Funciones (crear, comprar, ejecutar, devolver)

**Qué campos tiene cada Struct:**
- Todos los atributos que necesita
- Validaciones
- Relaciones entre structs

---

### 2️⃣ `02_audit.mmd`
**Qué es:** Detalles de `contexts/audit/`

**Muestra:**
- **audit_log.ex** → Struct para registrar TODAS las operaciones
  - Quién lo hizo
  - Qué acción
  - Cuándo
  - Si fue exitoso
  - Qué error si falló
- **operations.ex** → Funciones para:
  - Registrar acciones
  - Obtener historial
  - Buscar logs
  - Exportar

**Importante:** Aquí se guarda **TODO** que sucede en el sistema

---

### 3️⃣ `03_notifications.mmd`
**Qué es:** Detalles de `contexts/notifications/`

**Muestra:**
- **notification.ex** → Struct para notificaciones
  - Tipo (éxito, error, advertencia, info)
  - Mensaje
  - A quién va
  - Si ya fue leída
- **broadcaster.ex** → Funciones para:
  - Enviar a un jugador
  - Broadcast a todos
  - Broadcast por sorteo
  - Broadcast a admins

**Importante:** Esto es el WebSocket - comunicación **en tiempo real**

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Qué campos tiene un Draw? → `01_draws.mmd`
- ✅ Qué campos tiene un Ticket? → `01_draws.mmd`
- ✅ Qué campos tiene un Prize? → `01_draws.mmd`
- ✅ Qué funciones hay en operations.ex? → Cada `.mmd` tiene una sección
- ✅ Cómo funciona auditoría? → `02_audit.mmd`
- ✅ Cómo funciona WebSocket? → `03_notifications.mmd`

---

## 📁 Relación

- Estos **detallan** lo que se ve en `04_Server/01_full_structure.mmd`
- Se usan en los **flujos** de `06_Flows/`
