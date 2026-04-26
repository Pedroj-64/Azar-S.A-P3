# 07 Shared Code - Código Compartido

## 📊 Diagramas en esta carpeta

### 1️⃣ `01_structure.mmd`
**Qué es:** Estructura de `shared_code/` - código reutilizable

**Contiene:**

#### **models/**
Esquemas compartidos entre las 3 aplicaciones
- `user_schema.ex` → Estructura base de usuario
- `draw_schema.ex` → Estructura base de sorteo
- `ticket_schema.ex` → Estructura base de billete

#### **utils/**
Funciones reutilizables en todo el sistema

**Validaciones:**
- `validate_email()` - Valida emails
- `validate_document()` - Valida documentos/cédulas
- `validate_amount()` - Valida montos
- `validate_date()` - Valida fechas

**Cálculos:**
- `calculate_total_revenue()` - Ingresos totales
- `calculate_net_profit()` - Ganancia neta
- `calculate_winners()` - Números ganadores
- `calculate_fractions()` - Operaciones con fracciones

**Fechas:**
- `format_datetime()` - Formatea DateTime
- `is_past_date()` - Comprueba si pasó
- `days_until()` - Días hasta una fecha
- `date_difference()` - Diferencia entre fechas

---

## 🎯 Casos de uso

**¿Quiero entender...**
- ✅ Qué va en shared_code? → `01_structure.mmd`
- ✅ Qué funciones compartidas hay? → Sección utils/
- ✅ Cómo valido datos? → validations.ex
- ✅ Cómo calculo ingresos? → calculations.ex

---

## 📁 Nota Importante

**shared_code** es usado por:
- ✅ server/ → Para validar, calcular, etc
- ✅ admin_client/ → Para validar reportes
- ✅ player_client/ → Para validar datos

**No es una aplicación por sí sola**, es una **librería compartida**
