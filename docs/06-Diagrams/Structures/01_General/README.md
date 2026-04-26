# 01 General - Arquitectura General

## 📊 Diagramas en esta carpeta

### 1️⃣ `01_general_architecture.mmd`
**Qué es:** Visión de **alto nivel** del sistema completo

**Muestra:**
- Las 3 aplicaciones principales (Player, Admin, Server)
- Cómo se comunican (HTTP/WebSocket)
- Dónde se guardan los datos (JSON)
- El código compartido (shared_code)

**Cuándo usarlo:** Para entender cómo funciona el sistema en general

---

### 2️⃣ `02_complete_system_overview.mmd`
**Qué es:** Flujo completo de **una operación** (compra de billete)

**Muestra paso a paso:**
1. Jugador hace clic
2. Se envía HTTP al servidor
3. Se procesa en contexts/
4. Se crea el Ticket
5. Se guarda en JSON
6. Se registra en auditoría
7. Se envía notificación
8. Jugador ve confirmación

**Cuándo usarlo:** Para entender cómo una acción viaja por todo el sistema

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Cómo se conectan las 3 apps? → `01_general_architecture.mmd`
- ✅ Qué sucede cuando compro un billete? → `02_complete_system_overview.mmd`
- ✅ Dónde se guardan los datos? → Ambos
- ✅ Cómo funciona el WebSocket? → `02_complete_system_overview.mmd`
