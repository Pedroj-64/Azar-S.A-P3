# 📊 Índice de Structures - Organizadas por Carpetas

## 📂 Estructura de Carpetas

```
docs/Structures/
├── 01_General/              ← Arquitectura general
├── 02_PlayerClient/         ← Cliente de jugadores
├── 03_AdminClient/          ← Cliente de administración
├── 04_Server/               ← Servidor central
├── 05_Contexts/             ← Detalles de contextos
├── 06_Flows/                ← Flujos de operaciones
├── 07_SharedCode/           ← Código compartido
└── INDEX.md                 ← Este archivo
```

---

## 🎯 Guía Rápida

### 1️⃣ **Empezar aquí:** `01_General/`
Si **no sabes nada** del proyecto, empieza aquí:
- `01_general_architecture.mmd` - Cómo se conectan las 3 apps
- `02_complete_system_overview.mmd` - Un flujo completo

---

### 2️⃣ **Entiende Jugadores:** `02_PlayerClient/`
Si quieres saber cómo los jugadores usan el sistema:
- `01_structure.mmd` - Qué archivos hay
- `02_registration_flow.mmd` - Cómo se registran y compran

---

### 3️⃣ **Entiende Admins:** `03_AdminClient/`
Si quieres saber cómo los admins controlan el sistema:
- `01_structure.mmd` - Qué archivos hay
- `02_draw_creation_flow.mmd` - Cómo crean y ejecutan sorteos

---

### 4️⃣ **Entiende el Server:** `04_Server/`
Si quieres saber dónde ocurre la magia:
- `01_full_structure.mmd` - Estructura completa del servidor

**IMPORTANTE:** El server es el corazón, aquí ocurre todo

---

### 5️⃣ **Detalles Técnicos:** `05_Contexts/`
Si quieres saber exactamente qué campos tiene cada Struct:
- `01_draws.mmd` - Structs de Draw, Ticket, Prize
- `02_audit.mmd` - Struct de AuditLog
- `03_notifications.mmd` - Struct de Notification

---

### 6️⃣ **Flujos Paso a Paso:** `06_Flows/`
Si quieres ver exactamente qué sucede en orden:
- `01_purchase_flow.mmd` - Compra de billete paso a paso

---

### 7️⃣ **Código Compartido:** `07_SharedCode/`
Si quieres saber qué se reutiliza en todo el sistema:
- `01_structure.mmd` - Validaciones, cálculos, helpers

---

## 🎨 Código de Colores

Todos los diagramas usan los mismos colores:

| Color | Qué Significa |
|-------|---------------|
| 🟢 Verde | Structs (definición de datos) |
| 🔵 Azul | Funciones (lógica de negocio) |
| 🟠 Naranja | HTTP, Controllers |
| 🟣 Morado | WebSockets, Views |
| 🩷 Rosa | Notificaciones |
| 🟤 Marrón | JSON (persistencia) |
| 🟡 Amarillo | UI, Interfaces |

---

## 🚀 Rutas de Aprendizaje

### **Soy nuevo en el proyecto**
1. Lee `01_General/01_general_architecture.mmd`
2. Lee `01_General/02_complete_system_overview.mmd`
3. Ve `04_Server/README.md`
4. Luego elige tu área

### **Quiero entender jugadores**
1. `02_PlayerClient/01_structure.mmd`
2. `02_PlayerClient/02_registration_flow.mmd`
3. `05_Contexts/01_draws.mmd`
4. `06_Flows/01_purchase_flow.mmd`

### **Quiero entender admins**
1. `03_AdminClient/01_structure.mmd`
2. `03_AdminClient/02_draw_creation_flow.mmd`
3. `05_Contexts/01_draws.mmd`

### **Quiero entender el server**
1. `04_Server/01_full_structure.mmd`
2. `05_Contexts/01_draws.mmd`
3. `05_Contexts/02_audit.mmd`
4. `05_Contexts/03_notifications.mmd`
5. `06_Flows/01_purchase_flow.mmd`

### **Quiero entender todo**
Lee todas las carpetas en orden: 01 → 02 → 03 → 04 → 05 → 06 → 07

---

## 📖 Documentación Markdown

También hay archivos `.md` en cada carpeta con explicaciones detalladas:
- `01_General/README.md`
- `02_PlayerClient/README.md`
- `03_AdminClient/README.md`
- `04_Server/README.md`
- `05_Contexts/README.md`
- `06_Flows/README.md`
- `07_SharedCode/README.md`

---

## 💡 Consejos

1. **Empieza visual:** Abre los `.mmd` en https://mermaid.live
2. **Lee el README:** Cada carpeta tiene un README.md explicativo
3. **Sigue los números:** Los diagramas están numerados para leer en orden
4. **Haz zoom:** Los diagramas tienen muchos detalles
5. **Exporta:** Puedes descargar como PNG/SVG/PDF

---

## ✅ Checklist de Comprensión

- [ ] Entiendo que hay 3 aplicaciones (player, admin, server)
- [ ] Entiendo que el server es el centro
- [ ] Entiendo qué es contexts/
- [ ] Entiendo que todo se guarda en JSON
- [ ] Entiendo auditoría (se registra TODO)
- [ ] Entiendo WebSocket (notificaciones en tiempo real)
- [ ] Entiendo structs vs operations.ex
- [ ] Entiendo un flujo completo: entrada → lógica → salida
