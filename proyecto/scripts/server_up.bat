@echo off
:: scripts/server_up.bat

echo ----------------------------------------------------------
echo 🚀 INICIANDO SERVIDOR CENTRAL AZAR S.A. (WINDOWS)
echo ----------------------------------------------------------

:: Intentar obtener la IP (esto puede variar según la versión de Windows)
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4" ^| findstr /v "127.0.0.1"') do (
    set LOCAL_IP=%%a
    goto :found
)

:found
:: Quitar el espacio inicial de la IP encontrada
set LOCAL_IP=%LOCAL_IP:~1%

echo 📍 Tu IP local detectada es: %LOCAL_IP%
echo 🌐 Los otros PCs deben entrar a: http://%LOCAL_IP%:4000
echo 🍪 Cookie de seguridad: azar_sa_cookie
echo ----------------------------------------------------------

:: Iniciar el nodo con nombre y cookie
iex --name "server@%LOCAL_IP%" --cookie azar_sa_cookie -S mix phx.server
