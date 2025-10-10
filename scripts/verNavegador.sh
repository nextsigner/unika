#!/bin/bash

# Nombre del programa a buscar
PROGRAMA="Google Chrome"
# Ruta absoluta a wmctrl
WMCTRL="/usr/bin/wmctrl"
# Ruta absoluta a google-chrome
CHROME_BIN="/usr/bin/google-chrome"


# 1. Verificar si 'wmctrl' existe en la ruta absoluta.
if [ ! -f "$WMCTRL" ]; then
    echo "🚨 Error: La herramienta wmctrl no se encontró en $WMCTRL"
    exit 1
fi

# 2. Buscar la ventana usando la ruta absoluta
CHROME_WINDOW_ID=$("$WMCTRL" -l -i | grep "$PROGRAMA" | head -n 1 | awk '{print $1}')

# 3. Activar o Iniciar Chrome
if [ -z "$CHROME_WINDOW_ID" ]; then
    echo "🔍 No se encontró ninguna ventana de '$PROGRAMA' abierta."
    echo "Iniciando Google Chrome..."
    # Usar la ruta absoluta para iniciar Chrome
    "$CHROME_BIN" &
else
    echo "✅ Activando ventana de '$PROGRAMA' con ID: $CHROME_WINDOW_ID"
    # Usar la ruta absoluta para activar la ventana
    "$WMCTRL" -ia "$CHROME_WINDOW_ID"
fi
