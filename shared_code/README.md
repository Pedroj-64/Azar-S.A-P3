# Código Compartido - Azar S.A

## 📋 Descripción

Aplicación Elixir con módulos reutilizables entre las tres aplicaciones principales.

## 🏗️ Estructura de Directorios

```
shared_code/
├── lib/azar_shared/
│   ├── models/           # Structs compartidos
│   │   ├── sorteo.ex         # Struct de Sorteo
│   │   ├── usuario.ex        # Struct de Usuario
│   │   ├── compra.ex         # Struct de Compra
│   │   └── premio.ex         # Struct de Premio
│   │
│   ├── validation/       # Validadores
│   │   ├── email_validator.ex
│   │   ├── document_validator.ex
│   │   └── amount_validator.ex
│   │
│   ├── utils/            # Funciones utilitarias
│   │   ├── json_helper.ex       # Lectura/escritura JSON
│   │   ├── datetime_helper.ex   # Manejo de fechas
│   │   ├── string_helper.ex     # Operaciones en strings
│   │   └── crypto_helper.ex     # Criptografía y hashing
│   │
│   ├── constants.ex      # Constantes globales del sistema
│   └── errors.ex         # Definiciones de errores
│
├── test/                 # Tests de módulos compartidos
│
├── mix.exs              # Dependencias
└── README.md
```

## 📦 Módulos a Implementar

### `models/`
- **sorteo.ex** - Define la estructura y tipos de un Sorteo
- **usuario.ex** - Define la estructura de Usuario
- **compra.ex** - Define la estructura de Compra
- **premio.ex** - Define la estructura de Premio

### `validation/`
- **email_validator.ex** - Validar emails
- **document_validator.ex** - Validar documentos de identidad
- **amount_validator.ex** - Validar montos/valores

### `utils/`
- **json_helper.ex** - Funciones para leer/escribir archivos JSON
- **datetime_helper.ex** - Parsing y manejo de fechas ISO 8601
- **string_helper.ex** - Funciones auxiliares para strings
- **crypto_helper.ex** - Hash de contraseñas (bcrypt), tokens, UUID

### `constants.ex`
- Estados de sorteo (abierto, ejecutado, archivado)
- Tipos de compra (billete completo, fracción)
- Códigos de error del sistema
- Límites y restricciones
- Rutas de canales WebSocket
- Rutas de directorios

### `errors.ex`
- Definiciones de errores personalizados
- Códigos de error estándar

## 🔧 Configuración

En cada aplicación, agregar a `mix.exs`:

```elixir
defp deps do
  [
    {:azar_shared, path: "../shared_code"},
    # ... otras dependencias
  ]
end
```

## 🔄 Uso en Aplicaciones

```elixir
# En cualquier contexto
alias AzarShared.Models.Sorteo
alias AzarShared.Utils.JsonHelper
alias AzarShared.Constants
```

## 🧪 Testing

```bash
mix test
```

---

**Código reutilizable entre todas las aplicaciones** 🔗
