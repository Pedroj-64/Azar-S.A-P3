# PLAN DE ACCIÓN - REPARACIONES

**Fecha:** 26 de abril de 2026  
**Basado en:** DIAGNOSTICO.md  

---

## OBJETIVO

Convertir la estructura actual de "esqueleto completo + implementación incompleta" a "código funcional y consistente"

---

## PRIORIDADES

### FASE 1: CRÍTICO (Hoy)

**Tiempo estimado: 6-8 horas**

#### 1.1 - Renombrar Módulos - 2-3 horas

**Problema:**
```
admin_client/lib/azar_admin/ ← INCONSISTENTE
player_client/lib/azar_player/ ← INCONSISTENTE
```

**Solución:**
```
admin_client/lib/azar_admin_client/ ← CONSISTENTE
player_client/lib/azar_player_client/ ← CONSISTENTE
```

**Tareas:**
1. Crear carpetas azar_admin_client/ y azar_player_client/
2. Mover archivos
3. Actualizar module names en TODOS los .ex files
4. Actualizar imports
5. Tests de que compila: mix compile

---

#### 1.2 - Completar JSON Helpers - 1-2 horas

**Problema:**
En DrawOps se usa JsonHelper.append_to_json_array(@draws_file, draw)
Pero la función NO EXISTE

**Solución:** Agregar funciones a shared_code/lib/azar_shared/utils/json_helper.ex

```elixir
def append_to_json_array(file_path, element) do
  case read_file(file_path) do
    {:ok, data} ->
      array = data["items"] || []
      new_array = array ++ [element]
      write_file(file_path, %{"items" => new_array})
    {:error, _} ->
      write_file(file_path, %{"items" => [element]})
  end
end

def read_json_array(file_path) do
  case read_file(file_path) do
    {:ok, data} -> {:ok, data["items"] || []}
    error -> error
  end
end

def update_in_json_array(file_path, id, updated_element) do
  case read_json_array(file_path) do
    {:ok, array} ->
      updated = Enum.map(array, fn item ->
        if item["id"] == id, do: updated_element, else: item
      end)
      write_file(file_path, %{"items" => updated})
    error -> error
  end
end

def delete_from_json_array(file_path, id) do
  case read_json_array(file_path) do
    {:ok, array} ->
      updated = Enum.filter(array, fn item -> item["id"] != id end)
      write_file(file_path, %{"items" => updated})
    error -> error
  end
end
```

---

#### 1.3 - Crear Esquemas JSON - 1-2 horas

**Crear archivo:** docs/JSON_SCHEMAS.md

Define estructura para:
- draws.json
- purchases.json
- users.json
- audit_logs.json

**Crear archivo:** scripts/seed_data.exs

Script para inicializar datos de testing.

---

### FASE 2: IMPORTANTE (Esta semana)

**Tiempo estimado: 8-10 horas**

#### 2.1 - Implementar Player Operations - 4-5 horas

**Archivos:** 
- player_client/lib/azar_player_client/contexts/purchases/operations/operations.ex
- player_client/lib/azar_player_client/contexts/users/operations/operations.ex

**Funciones purchases/operations/operations.ex:**
- validate_purchase_attrs/1
- persist_purchase/1
- calculate_purchase_price_internal/3
- validate_return_eligibility/1
- process_refund_internal/2

**Funciones users/operations/operations.ex:**
- validate_registration_attrs/1
- persist_user/1
- authenticate_internal/2
- validate_password_strength/1
- credit_balance_internal/3
- debit_balance_internal/3

---

#### 2.2 - Crear Admin Client - 6-8 horas

**Estructura completa:**
```
admin_client/lib/azar_admin_client/
├── contexts/
│   ├── users/
│   │   ├── admin_user.ex (existe)
│   │   ├── operations.ex (NEW)
│   │   └── operations/operations.ex (NEW)
│   ├── reports/
│   │   ├── income_report.ex (existe)
│   │   ├── operations.ex (NEW)
│   │   └── operations/operations.ex (NEW)
│   ├── draws/
│   │   ├── draw_management.ex (NEW)
│   │   ├── operations.ex (NEW)
│   │   └── operations/operations.ex (NEW)
│   └── prizes/
│       ├── prize_management.ex (NEW)
│       ├── operations.ex (NEW)
│       └── operations/operations.ex (NEW)
└── controllers/
    ├── admin_user_controller.ex (NEW)
    ├── draw_controller.ex (NEW)
    ├── report_controller.ex (NEW)
    └── prize_controller.ex (NEW)
```

**Operaciones a crear:**
- AdminUserOperations (login, registro admin, cambiar permisos)
- DrawManagementOperations (CRUD de sorteos para admin)
- PrizeManagementOperations (CRUD de premios)
- IncomeReportOperations (cálculo de ingresos)

---

### FASE 3: MEJORA (Próxima semana)

**Tiempo estimado: 8-10 horas**

#### 3.1 - Autenticación (AuthPlug) - 3-4 horas
#### 3.2 - Transacciones/Rollback - 4-5 horas
#### 3.3 - Tests unitarios - 8-10 horas
#### 3.4 - Validación centralizada - 2-3 horas

---

## MAPA DE DEPENDENCIAS

```
Fase 1 (Hoy)
├── 1.1 Renombrar
├── 1.2 JSON Helpers
└── 1.3 Esquemas JSON

Fase 2 (Esta semana)
├── 2.1 Player Operations (depende: 1.1, 1.2)
└── 2.2 Admin Client (depende: 1.1, 1.2, 1.3)

Fase 3 (Próxima semana)
├── 3.1 AuthPlug (depende: 2.1, 2.2)
└── 3.2-3.4 Quality
```

---

## CHECKLIST FINAL

### Compilación
- [ ] Admin client compila sin errores
- [ ] Player client compila sin errores
- [ ] Server compila sin errores
- [ ] Shared code compila sin errores

### JSON Storage
- [ ] draws.json existe con estructura correcta
- [ ] purchases.json existe
- [ ] users.json existe
- [ ] audit_logs.json existe
- [ ] JsonHelper tiene todas las funciones

### Operaciones
- [ ] Player purchases/operations completo
- [ ] Player users/operations completo
- [ ] Admin users/operations completo
- [ ] Admin draws/operations completo
- [ ] Admin prizes/operations completo
- [ ] Admin reports/operations completo

### Controllers
- [ ] Admin controllers creados (4)
- [ ] Todos los endpoints funcionan
- [ ] Parámetros validados

### Integración
- [ ] AdminClient puede crear sorteos
- [ ] PlayerClient puede comprar
- [ ] Server procesa correctamente
- [ ] Auditoría registra

---

## CÓMO EJECUTAR

### Paso 1: FASE 1 (Hoy)
```bash
# 1.1 Renombrar (manual con editor)
# 1.2 Implementar JSON helpers en shared_code
mix test shared_code

# 1.3 Crear documentación
```

### Paso 2: FASE 2 (Esta semana)
```bash
# 2.1 Implementar player operations
mix test player_client

# 2.2 Crear admin client
mix test admin_client
```

### Paso 3: Validación
```bash
mix compile
mix test
```

---

**Creado:** 26 de abril de 2026  
**Estimado:** 20-24 horas de trabajo  
**Prioridad:** CRÍTICO
