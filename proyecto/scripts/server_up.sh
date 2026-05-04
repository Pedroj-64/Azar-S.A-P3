#!/bin/bash
# scripts/server_up.sh

# 1. Intentar detectar la IP local automáticamente
LOCAL_IP=$(hostname -I | awk '{print $1}')

if [ -z "$LOCAL_IP" ]; then
    # Fallback para macOS
    LOCAL_IP=$(ipconfig getifaddr en0)
fi

echo "----------------------------------------------------------"
echo "🚀 INICIANDO SERVIDOR CENTRAL AZAR S.A."
echo "----------------------------------------------------------"
echo "📍 Tu IP local es: $LOCAL_IP"
echo "🌐 Los otros PCs deben entrar a: http://$LOCAL_IP:4000"
echo "🍪 Cookie de seguridad: azar_sa_cookie"
echo "----------------------------------------------------------"

# Iniciar el nodo de Elixir con nombre y cookie
# Esto permite que otros nodos de Elixir se conecten si es necesario
iex --name "server@$LOCAL_IP" --cookie azar_sa_cookie -S mix phx.server
