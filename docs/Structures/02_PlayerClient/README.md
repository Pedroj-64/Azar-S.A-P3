# 02 Player Client - Cliente de Jugadores

## 📊 Diagramas en esta carpeta

### 1️⃣ `01_structure.mmd`
**Qué es:** Estructura **completa** del Player Client

**Muestra:**
- Carpetas y archivos dentro de `player_client/`
- Los 2 contexts: `users/` y `purchases/`
- Cada context tiene: struct + operations.ex
- Channels, controllers, views
- Relación entre componentes

**Colores:**
- 🟢 Verde = Structs (define datos)
- 🔵 Azul = Operations (funciones)
- 🟠 Naranja = Channels (WebSocket)
- 🔴 Rojo = Controllers (HTTP)
- 🟣 Morado = Views (respuestas)

---

### 2️⃣ `02_registration_flow.mmd`
**Qué es:** Flujo completo de **un jugador**: registro → compra

**Pasos:**
1. Jugador se registra (crea `PlayerUser`)
2. Guarda en JSON
3. Hace login
4. Ve sorteos disponibles
5. Selecciona billete
6. Realiza compra
7. Se crea `Purchase`
8. Se registra en auditoría
9. Recibe notificación
10. Ve confirmación

**Colores:**
- 🟢 Operaciones exitosas
- 🔵 Procesamiento del servidor
- 🟠 Persistencia
- 🟣 Notificaciones

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Qué archivos hay en player_client? → `01_structure.mmd`
- ✅ Cómo se registra un jugador? → `02_registration_flow.mmd`
- ✅ Cómo compra un billete? → `02_registration_flow.mmd`
- ✅ Qué es contexts/users/? → `01_structure.mmd`
- ✅ Qué es contexts/purchases/? → `01_structure.mmd`

---

## 📁 Relación con otras carpetas

- Habla con **04_Server** para procesar compras
- Usa **05_Contexts** para entender la lógica
- Usa **06_Flows** para ver flujos completos
