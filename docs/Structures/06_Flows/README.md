# 06 Flows - Flujos de Operaciones

## 📊 Diagramas en esta carpeta

Son **flujos secuenciales** que muestran **paso a paso** qué sucede

### 1️⃣ `01_purchase_flow.mmd`
**Qué es:** Flujo de **compra de billete** (el más importante)

**Actores:**
- 🎮 Jugador (usuario final)
- 📱 Player UI (interfaz)
- ⚙️ Server contexts/ (lógica)
- 📝 Audit (auditoría)
- 💾 JSON Files (persistencia)
- 📢 Notifications (WebSocket)

**Pasos:**
1. Jugador quiere comprar
2. PlayerUI envía HTTP
3. Server valida en contexts/draws/operations
4. Lee del JSON
5. Crea el Ticket
6. Escribe en JSON
7. Auditoría registra
8. Notificación se envía por WebSocket
9. Jugador ve confirmación

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Qué sucede cuando compro un billete? → `01_purchase_flow.mmd`
- ✅ En qué orden ocurren las cosas? → Sigue los números
- ✅ Quién habla con quién? → Mira las flechas
- ✅ Dónde se guardan los datos? → Flechas a "JSON Files"

---

## 📁 Nota

Este es el flujo más importante porque:
- Muestra cómo funciona el sistema completo
- Muestra todas las capas interactuando
- Es un ejemplo de cualquier operación en el sistema
