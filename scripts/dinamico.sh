#!/usr/bin/env bash

CACHE_FILE="$HOME/.cache/titan_wallpaper_state"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Live"

#!/usr/bin/env bash

CACHE_FILE="$HOME/.cache/titan_wallpaper_state"
WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Live"

# 1. LÓGICA DE MEMORIA Y AUTO-DETECCIÓN
if [ -n "$1" ]; then
    VIDEO="$1"
    BASE="${VIDEO%.*}" # Le quita el .mp4 al nombre

    # Auto-detectar la imagen compañera
    if [ -f "$WALLPAPER_DIR/$BASE.png" ]; then
        CAPTURA="$BASE.png"
    else
        CAPTURA="$BASE.jpg"
    fi
    
    echo "$VIDEO|$CAPTURA" > "$CACHE_FILE"
else
    if [ -f "$CACHE_FILE" ]; then
        IFS='|' read -r VIDEO CAPTURA < "$CACHE_FILE"
    else
        echo "No hay fondo en memoria."
        exit 1
    fi
fi

# 2. Matar procesos conflictivos
pkill mpvpaper
pkill hyprpaper 

# 3. Lanzar video en TODOS los monitores simultáneamente (Ultra optimizado)
# El asterisco '*' le dice a mpvpaper que cubra todas las pantallas detectadas por Wayland
mpvpaper -o "loop hwdec=auto --no-audio" '*' "$WALLPAPER_DIR/$VIDEO" > /dev/null 2>&1 &

# 4. Generar colores
matugen image "$WALLPAPER_DIR/$CAPTURA" -c ~/Titan-OS/matugen/matugen.toml --source-color-index 0
