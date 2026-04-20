# Requisitos del Sistema - Azar S.A

## 📋 Requisitos Funcionales

### RF1: Servidor Central

#### RF1.1 Procesamiento de Solicitudes
- [x] Recibir solicitudes de clientes a través de HTTP/WebSocket
- [x] Validar autenticación y autorización
- [x] Redirigir a servidor especializado según sorteo
- [x] Registrar auditoría de operaciones

#### RF1.2 Gestión de Servidores de Sorteo
- [x] Un servidor por cada sorteo
- [x] Crear/destruir servidores dinámicamente
- [x] Mantener estado en archivos JSON
- [x] Supervisar procesos con OTP

#### RF1.3 Notificaciones
- [x] Enviar resultados ganadores
- [x] Notificar en tiempo real (WebSocket)
- [x] Almacenar en base de datos en memoria

### RF2: Gestión de Sorteos (Admin Client)

#### RF2.1 Crear Sorteos
```
Entrada:
- Nombre del sorteo
- Fecha de ejecución
- Valor billete completo
- Cantidad de fracciones
- Cantidad de billetes

Salida:
- ID único del sorteo
- Confirmación de creación
```

#### RF2.2 Listar Sorteos
- Ordenar por fecha
- Mostrar premios asociados
- Indicar estado (abierto/ejecutado)
- Para ejecutados: mostrar ganadores

#### RF2.3 Eliminar Sorteos
- Solo permitir si no tiene premios
- Validar integridad de datos

#### RF2.4 Consultar Clientes de Sorteo
- Agrupar por tipo: billete completo / fracciones
- Ordenar alfabéticamente
- Mostrar cantidad comprada

#### RF2.5 Ingresos y Reportes
- Consultar ingresos por sorteo
- Calcular ganancias/pérdidas
- Mostrar premios entregados
- Resumen acumulado histórico

### RF3: Gestión de Premios (Admin Client)

#### RF3.1 Crear Premios
```
Entrada:
- Nombre del premio
- Valor del premio
- Sorteo asociado

Validación:
- No duplicar nombres en mismo sorteo
- Valor > 0
```

#### RF3.2 Listar Premios
- Ordenar por fecha creación
- Agrupar por sorteo
- Mostrar cantidad de ganadores

#### RF3.3 Eliminar Premios
- Solo si sorteo no tiene clientes
- Confirmar operación

#### RF3.4 Actualizar Fecha del Sistema
- Ejecutar sorteos pendientes hasta fecha actual
- Asignar números ganadores aleatoriamente
- Enviar notificaciones a jugadores

### RF4: Registro de Usuario (Player Client)

#### RF4.1 Crear Cuenta
```
Datos requeridos:
- Nombre completo
- Número documento
- Contraseña
- Tarjeta crédito (simulada)

Validación:
- Documento único
- Contraseña fuerte (min 8 caracteres)
```

#### RF4.2 Autenticación
- Login con documento/contraseña
- Mantener sesión activa
- Logout seguro

### RF5: Compra de Billetes (Player Client)

#### RF5.1 Consultar Sorteos Disponibles
- Solo sorteos no ejecutados
- Mostrar información: fecha, valor, premios
- Filtrar por estado

#### RF5.2 Consultar Números Disponibles
- Billetes completos disponibles
- Fracciones disponibles por billete
- Actualizar en tiempo real

#### RF5.3 Realizar Compra
```
Flujo:
1. Seleccionar sorteo
2. Elegir billete completo o fracción
3. Validar disponibilidad
4. Procesar pago (simulado)
5. Guardar compra
6. Enviar confirmación

Datos guardados:
- ID compra
- Usuario
- Sorteo
- Número billete/fracción
- Valor
- Fecha/hora
```

#### RF5.4 Devolver Compra
- Permitir solo antes de ejecutarse sorteo
- Reembolsar dinero
- Liberar número de billete

### RF6: Consultas y Reportes (Player Client)

#### RF6.1 Historial de Compras
- Mostrar todas las compras
- Total gastado
- Agrupar por sorteo
- Mostrar estado (activo/premiado/vencido)

#### RF6.2 Premios Obtenidos
- Listar premios ganados
- Valor de cada premio
- Fecha de ejecución
- Estado de cobro

#### RF6.3 Balance Personal
```
Cálculo:
- Total gastado en compras
- Total obtenido en premios
- Diferencia (ganancia/pérdida)
- Porcentaje de retorno
```

#### RF6.4 Notificaciones
- Ver resultados de sorteos
- Alertas de cambios en sorteos
- Mensajes del servidor
- Historial de notificaciones

---

## 🔐 Requisitos No Funcionales

### RNF1: Seguridad
- [x] Autenticación por credenciales
- [x] Validación de entrada en todos los endpoints
- [x] Contraseñas hasheadas (bcrypt)
- [x] Sesiones con tokens
- [x] Auditoría de operaciones sensibles

### RNF2: Rendimiento
- [x] Soportar 1000+ usuarios concurrentes
- [x] Respuesta < 500ms en operaciones críticas
- [x] Sincronización en tiempo real (< 100ms)

### RNF3: Disponibilidad
- [x] Uptime 99%
- [x] Recuperación ante fallos (supervisores)
- [x] Persistencia de datos en JSON

### RNF4: Escalabilidad
- [x] Agregar nuevos sorteos dinámicamente
- [x] Distribuir carga entre servidores

### RNF5: Mantenibilidad
- [x] Código modular y documentado
- [x] Tests unitarios para contextos
- [x] Logs detallados
- [x] Fácil actualización

### RNF6: Compatibilidad
- [x] Navegadores modernos (Chrome, Firefox, Safari)
- [x] Responsive design
- [x] Elixir 1.17+
- [x] Erlang/OTP 27+

---

## 📊 Casos de Uso Principales

### CU1: Crear Sorteo
**Actor**: Administrador  
**Precondición**: Logueado en admin client  
**Flujo**:
1. Ingresar datos del sorteo
2. Validar campos
3. Crear registro en JSON
4. Retornar ID
5. Iniciar servidor de sorteo

### CU2: Comprar Billete
**Actor**: Jugador  
**Precondición**: Logueado, sorteo activo  
**Flujo**:
1. Ver sorteos disponibles
2. Seleccionar sorteo y número
3. Validar disponibilidad
4. Procesar pago
5. Guardar compra
6. Actualizar estado en servidor

### CU3: Ejecutar Sorteo
**Actor**: Administrador  
**Precondición**: Sorteo abierto con premios  
**Flujo**:
1. Seleccionar sorteo
2. Validar fecha
3. Generar números ganadores
4. Calcular ganadores
5. Notificar jugadores
6. Guardar estado

---

## 📝 Restricciones Técnicas

| Restricción | Detalles |
|---|---|
| Lenguaje | Elixir 1.17+ |
| Framework | Phoenix |
| Base de datos | JSON (sin SQL) |
| Comunicación | HTTP + WebSocket |
| Persistencia | Archivos en `priv/data/` |
| Logging | Archivos en `priv/logs/` |
| Autenticación | Token-based (sesiones) |

---

**Versión**: 1.0  
**Última actualización**: Abril 2026
