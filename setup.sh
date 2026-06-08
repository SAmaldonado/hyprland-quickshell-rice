#!/usr/bin/env bash

# ==============================================================================
# TITAN-OS: Script de Despliegue y Automatización (Symlinks & Auditoría)
# ==============================================================================

GREEN="\e[32m"
BLUE="\e[34m"
YELLOW="\e[33m"
RED="\e[31m"
BOLD="\e[1m"
NC="\e[0m"

REPO_DIR="$HOME/Titan-OS"
REPO_QS="$REPO_DIR/quickshell"
REPO_SCRIPTS="$REPO_DIR/scripts"
TARGET_CONFIG="$HOME/.config/quickshell"
TARGET_BIN="$HOME/.local/bin"
LOG_DIR="$HOME/.cache/titan"

mkdir -p "$TARGET_BIN" "$LOG_DIR" "$HOME/.config/matugen" "$HOME/Pictures/Wallpapers/Live"

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}${BOLD}[ERROR]${NC} $1"; }

print_banner() {
    echo -e "${BOLD}${GREEN}"
    echo "  _______ _____ _______       _   _        ____   ____  "
    echo " |__   __|_   _|__   __|     | \ | |      / __ \ / ____| "
    echo "    | |    | |    | |   ____ |  \| |_____| |  | | (___   "
    echo "    | |    | |    | |  / _  || . \` |_____| |  | |\___ \  "
    echo "    | |   _| |_   | | | (_| || |\  |     | |__| |____) | "
    echo "    |_|  |_____|  |_|  \__,_||_| \_|      \____/|_____/  "
    echo -e "                                    Gestión de Entorno${NC}\n"
}

auditar_dependencias() {
    log_info "Iniciando auditoría de componentes críticos para el Titán..."
    local faltantes=0
    declare -A deps=( ["quickshell"]="Quickshell" ["hyprctl"]="Hyprland" ["matugen"]="Matugen" ["mpvpaper"]="Mpvpaper" ["jq"]="JQ" ["playerctl"]="Playerctl" ["dbus-broker"]="D-Bus Broker" )

    for cmd in "${!deps[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            log_success "Detectado: ${deps[$cmd]}"
        else
            log_warn "Faltante: ${deps[$cmd]} -> Instalar con pacman/yay"
            faltantes=$((faltantes + 1))
        fi
    done

    if [ "$faltantes" -eq 0 ]; then
        log_success "¡Auditoría superada con éxito!"
    else
        log_warn "Faltan $faltantes herramientas. El sistema podría no responder al 100%."
    fi
}

crear_enlaces() {
    log_info "Sincronizando configuraciones mediante enlaces simbólicos..."

    if [ -d "$REPO_QS" ]; then
        if [ -d "$TARGET_CONFIG" ] && [ ! -L "$TARGET_CONFIG" ]; then
            log_warn "Se detectó carpeta vieja en $TARGET_CONFIG. Creando respaldo..."
            mv "$TARGET_CONFIG" "${TARGET_CONFIG}_backup_$(date +%s)"
        fi
        rm -rf "$TARGET_CONFIG"
        ln -snf "$REPO_QS" "$TARGET_CONFIG"
        log_success "Enlace desplegado: $REPO_QS -> $TARGET_CONFIG"
    else
        log_error "No se encontró 'quickshell' en $REPO_QS."
    fi

    if [ -d "$REPO_SCRIPTS" ]; then
        log_info "Desplegando ejecutables en PATH..."
        for script in "$REPO_SCRIPTS"/*; do
            if [ -f "$script" ]; then
                name=$(basename "$script")
                chmod +x "$script"
                ln -sf "$script" "$TARGET_BIN/$name"
                log_success "Script enlazado: $name -> $TARGET_BIN/$name"
            fi
        done
    else
        log_warn "No se encontró 'scripts'. Creándola ahora..."
        mkdir -p "$REPO_SCRIPTS"
    fi
}

print_banner
auditar_dependencias
echo ""
crear_enlaces
echo ""
log_success "¡Proceso terminado! El Titán está listo."
