# Scripts de Utilidad - Azar S.A

## 📋 Descripción

Scripts bash para tareas comunes del proyecto.

## 🛠️ Scripts a Implementar

### `setup.sh`
Configuración inicial del proyecto:
- Verificar requisitos (Elixir, Mix, Node.js)
- Crear directorios de datos
- Instalar dependencias de todas las apps
- Compilar todas las apps
- Crear archivos JSON iniciales

**Uso:**
```bash
bash scripts/setup.sh
```

### `start.sh`
Inicia todas las aplicaciones en paralelo:
- Servidor (puerto 4000)
- Admin Client (puerto 4001)
- Player Client (puerto 4002)

**Uso:**
```bash
bash scripts/start.sh
```

### `dev.sh`
Entorno de desarrollo (opcional):
- Iniciar servidor con live reload
- Iniciar con IEx interactivo

**Uso:**
```bash
bash scripts/dev.sh
```

### `test.sh`
Ejecutar todos los tests:
- Tests del servidor
- Tests del admin client
- Tests del player client
- Tests del código compartido

**Uso:**
```bash
bash scripts/test.sh
```

### `clean.sh`
Limpiar compilaciones y dependencias:
- Eliminar `_build/`
- Eliminar `deps/`
- Eliminar archivos temporales

**Uso:**
```bash
bash scripts/clean.sh
```

### `seed_data.exs`
Script Elixir para poblar datos iniciales:
- Crear sorteos de prueba
- Crear usuarios de prueba
- Crear premios de prueba
- Guardar en JSON

**Uso:**
```bash
mix run scripts/seed_data.exs
```

## 📝 Convenciones

- Todos los scripts bash deben ser ejecutables: `chmod +x scripts/*.sh`
- Usar `set -e` para detener en caso de error
- Agregar colores para mejor legibilidad (rojo, verde, amarillo)
- Mostrar status de cada paso

---

**Scripts para facilitar el desarrollo** 🚀
