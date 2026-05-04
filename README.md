# Azar S.A. - Sistema de Sorteos Distribuido

Este proyecto es una solución integral para la gestión de juegos de azar, desarrollada en **Elixir** utilizando el **Phoenix Framework**. El sistema está diseñado siguiendo los principios de sistemas distribuidos y concurrencia de la viga (BEAM), utilizando procesos OTP para cada sorteo.

## 🏗️ Arquitectura del Sistema

El proyecto está organizado bajo una arquitectura limpia y modular, separando la lógica de negocio (Core) de la interfaz de usuario (Web).

### Estructura de Carpetas (Backend - `lib/proyecto/core`)

La lógica central reside en `lib/proyecto/core`, dividida en capas claras:

*   **`data/`**: Contiene `Store.ex`, el motor de persistencia que maneja la lectura y escritura de archivos **JSON** (sin base de datos SQL).
*   **`domain/`**: Define las entidades y constructores del sistema (`Client`, `Draw`, `Prize`, `Purchase`). Aquí se asegura la integridad de los datos.
*   **`servers/`**: El corazón concurrente del sistema.
    *   `CentralServer.ex`: El orquestador principal (fachada) que recibe todas las peticiones.
    *   `DrawServer.ex`: GenServer dinámico; cada sorteo activo en el sistema es un proceso independiente con su propio estado.
    *   `DrawSupervisor.ex`: Supervisor dinámico que gestiona el ciclo de vida de los procesos de sorteo.
*   **`services/`**: Capa de lógica de negocio y consultas complejas.
    *   `AdminService.ex`: Gestión y autenticación de administradores.
    *   `Cliente_service.ex`: Lógica de jugadores, saldos y autenticación.
    *   `DrawService.ex`: Consultas de balances, premios y reportes de sorteos.
*   **`support/`**: Infraestructura y servicios de soporte.
    *   `AuditLogger.ex`: Bitácora obligatoria que registra cada operación en consola y en `priv/logs/bitacora.txt`.
    *   `NotificationServer.ex`: Sistema de mensajería en memoria para notificar a los jugadores.
    *   `SystemDate.ex`: Control de la fecha del sistema para la ejecución automática de sorteos.

### Capa Web (`lib/proyecto_web`)

*   **`live/`**: Directorio para los componentes de **Phoenix LiveView**, separados en `admin/` y `player/`.
*   **`helpers/error_helpers.ex`**: Centraliza la internacionalización (**i18n**), convirtiendo átomos del backend en mensajes traducidos.
*   **`plugs/`**: Middlewares para detectar el idioma (`Locale`) y gestionar la sesión.

---

## 🌍 Internacionalización (i18n)

El sistema soporta múltiples idiomas (Español e Inglés) mediante **Gettext**.
*   Los mensajes de error en el backend son siempre **átomos** (ej: `{:error, :number_taken}`).
*   Las traducciones se encuentran en `priv/gettext/`.

---

## 🚀 Cómo empezar

### Requisitos
*   Elixir 1.14 o superior.
*   Erlang/OTP 25 o superior.

### Instalación
1.  Instalar dependencias:
    ```bash
    mix deps.get
    ```
2.  Cargar datos de prueba (Clientes, Sorteos, Administrador):
    ```bash
    mix run priv/seeds.exs
    ```
    *Nota: Esto crea un admin por defecto (usuario: `admin`, clave: `admin123`).*

3.  Iniciar el servidor:
    ```bash
    mix phx.server
    ```

---

## 📝 Bitácora (Logging)
Todas las solicitudes y sus resultados (OK/ERROR) se registran automáticamente en:
`priv/logs/bitacora.txt`

---

## 🌐 Pruebas en dos Computadores (Sistemas Distribuidos)

Para cumplir con el requisito de "entorno distribuido real", el sistema permite conectar múltiples nodos de Elixir en red.

### 1. En el Computador SERVIDOR:
Ejecuta el script de arranque (detectará tu IP automáticamente):
*   **Linux/Mac**: `./scripts/server_up.sh`
*   **Windows**: `scripts\server_up.bat`

### 2. En el Computador CLIENTE:
*   **Vía Web**: Abre el navegador y entra a `http://IP_DEL_SERVIDOR:4000`. Verás los cambios en tiempo real gracias a WebSockets.
*   **Vía Consola Elixir (Cluster)**: Si quieres demostrar que los nodos están conectados por Erlang, ejecuta:
    `./scripts/connect_console.sh IP_DEL_SERVIDOR`

---

## 🛠️ Tecnologías utilizadas
*   **Elixir & OTP**: Concurrencia, Procesos, Supervisores y Registry.
*   **Phoenix Framework**: Interfaz web en tiempo real con LiveView.
*   **Jason**: Serialización de datos JSON para persistencia.
*   **Gettext**: Soporte multilenguaje.

---

## ⚡ Optimización y Rendimiento

El sistema ha sido optimizado para soportar alta carga y baja latencia:

1.  **Descentralización de Procesos**: El `CentralServer` actúa como un enrutador inteligente. Las operaciones de compra y consulta de tickets se realizan directamente sobre los procesos `DrawServer` individuales, eliminando cuellos de botella.
2.  **Notificaciones en Tiempo Real (PubSub)**: Utiliza `Phoenix.PubSub` para enviar notificaciones "push" a los clientes al instante.
3.  **I/O en Paralelo**: La lectura de sorteos desde disco se realiza de forma paralela utilizando `Task.async_stream`, aprovechando todos los núcleos del procesador.
