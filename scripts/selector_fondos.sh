#!/usr/bin/env bash

WALLPAPER_DIR="$HOME/Pictures/Wallpapers/Live"

# 1. Leer todos los videos .mp4 y quitarles la extensión para que el menú se vea limpio
OPCIONES=$(ls -1 "$WALLPAPER_DIR"/*.mp4 | xargs -n 1 basename | sed 's/\.mp4$//')

# 2. Abrir Fuzzel en el centro de la pantalla para que elijas
# (Puedes personalizar los colores de Fuzzel después para que combinen con tu tema)
ELECCION=$(echo "$OPCIONES" | fuzzel --dmenu --prompt "🎬 Atmósfera: " --lines 10 --width 40)

# Si presionas Esc o cierras el menú, el script se cancela en silencio
if [ -z "$ELECCION" ]; then
    exit 0
fi

# 3. Reconstruir el nombre del video
VIDEO="${ELECCION}.mp4"

# 4. Magia negra: Buscar automáticamente si la captura es .png o .jpg
if [ -f "$WALLPAPER_DIR/${ELECCION}.png" ]; then
    CAPTURA="${ELECCION}.png"
elif [ -f "$WALLPAPER_DIR/${ELECCION}.jpg" ]; then
    CAPTURA="${ELECCION}.jpg"
else
    # Si olvidas poner la imagen de captura, te avisa y aborta
    notify-send "Error de Titán" "No encontré una imagen .png o .jpg para el video $ELECCION"
    exit 1
fi

# 5. Ejecutar el cambio global de colores y fondo
~/.local/bin/dinamico.sh "$VIDEO" "$CAPTURA"
