#!/bin/bash
# scripts/connect_console.sh

if [ -z "$1" ]; then
    echo "❌ Error: Debes pasar la IP del servidor como primer parámetro."
    echo "Uso: ./scripts/connect_console.sh 192.168.1.XX"
    exit 1
fi

SERVER_IP=$1
# Obtener mi propia IP para el nombre del nodo
MY_IP=$(hostname -I | awk '{print $1}')

if [ -z "$MY_IP" ]; then
    MY_IP=$(ipconfig getifaddr en0)
fi

echo "----------------------------------------------------------"
echo "🔗 CONECTANDO A SERVIDOR AZAR S.A. ($SERVER_IP)"
echo "----------------------------------------------------------"

# Iniciar nodo cliente y conectarse al servidor
iex --name "client@$MY_IP" --cookie azar_sa_cookie -S mix --eval "Node.connect(:'server@$SERVER_IP')"
