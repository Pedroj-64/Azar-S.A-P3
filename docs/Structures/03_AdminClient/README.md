# 03 Admin Client - Cliente de Administración

## 📊 Diagramas en esta carpeta

### 1️⃣ `01_structure.mmd`
**Qué es:** Estructura **completa** del Admin Client

**Muestra:**
- Carpetas y archivos dentro de `admin_client/`
- Los 2 contexts: `users/` y `reports/`
- Cada context tiene: struct + operations.ex
- Channels, controllers, views
- Diferencia con Player Client

**Colores:**
- 🟢 Verde = Structs (define datos)
- 🔵 Azul = Operations (funciones)
- 🩷 Rosa = Channels (WebSocket admin)
- 🔴 Rojo = Controllers (HTTP admin)
- 🟣 Morado = Views (reportes JSON)

---

### 2️⃣ `02_draw_creation_flow.mmd`
**Qué es:** Flujo completo: **crear sorteo → ejecutar → notificar**

**Pasos Crear:**
1. Admin relleña formulario
2. Envía HTTP POST
3. Server crea `Draw` struct
4. Guarda en JSON
5. Registra en auditoría
6. Notifica a todos
7. Panel se actualiza

**Pasos Ejecutar:**
8. Admin hace clic "Ejecutar"
9. Server genera números ganadores
10. Busca tickets ganadores
11. Asigna premios
12. Guarda cambios
13. Registra en auditoría
14. Notifica a TODOS los jugadores
15. Jugadores ven ganadores

**Colores:**
- 🟡 Acciones admin
- 🔵 Procesamiento
- 🟠 Persistencia
- 🟣 Notificaciones

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Qué archivos hay en admin_client? → `01_structure.mmd`
- ✅ Cómo crea un admin un sorteo? → `02_draw_creation_flow.mmd`
- ✅ Cómo se ejecuta un sorteo? → `02_draw_creation_flow.mmd`
- ✅ Qué es contexts/users/ en admin? → `01_structure.mmd`
- ✅ Qué es contexts/reports/? → `01_structure.mmd`

---

## 📁 Relación con otras carpetas

- Habla con **04_Server** para crear/ejecutar sorteos
- Usa **05_Contexts** para entender la lógica de draws/
- Ve **06_Flows** para entender operaciones
