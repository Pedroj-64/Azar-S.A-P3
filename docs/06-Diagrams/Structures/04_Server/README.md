# 04 Server - Servidor Central

## 📊 Diagramas en esta carpeta

### 1️⃣ `01_full_structure.mmd`
**Qué es:** Estructura **completa** del Server (el corazón del sistema)

**Muestra:**
- Carpetas dentro de `server/lib/azar_server/`
- 3 contexts principales: `draws/`, `audit/`, `notifications/`
- Cada context tiene múltiples archivos
- Channels, controllers, views
- Almacenamiento en `priv/data/` (JSON)

**Colores:**
- 🟢 Verde = Structs (draw.ex, ticket.ex, prize.ex)
- 🔵 Azul = Operations.ex (funciones de negocio)
- 🟠 Naranja = Auditoría
- 🩷 Rosa = Notificaciones
- 🟣 Morado = Channels, Controllers, Views
- 🟤 Marrón = JSON (persistencia)

**Este es el más importante - aquí va toda la lógica del sistema**

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Qué archivo hay en server/? → `01_full_structure.mmd`
- ✅ Dónde está la lógica de sorteos? → contexts/draws/
- ✅ Dónde se registran las operaciones? → contexts/audit/
- ✅ Cómo se notifica a jugadores? → contexts/notifications/
- ✅ Dónde se guardan los datos? → priv/data/ (JSON)

---

## 📁 Relación con otras carpetas

- **02_PlayerClient** envía requests aquí
- **03_AdminClient** envía requests aquí
- **05_Contexts** explica cada context en detalle
- **06_Flows** muestra cómo interactúan todos

---

## ⚙️ Nota importante

El SERVER es donde ocurre la "**magia**":
- Recibe requests HTTP de ambos clientes
- Procesa en contexts/
- Guarda en JSON
- Registra auditoría
- Envía notificaciones por WebSocket
- **TODO pasa aquí**
