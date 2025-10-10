#!/bin/bash

# --- Configuración ---
# Cadena de texto a buscar en el título de la ventana
TITULO_BUSCADO="Zool"
# Ruta absoluta a wmctrl (necesario para QProcess)
WMCTRL="/usr/bin/wmctrl"
# Nombre del ejecutable del programa (¡AJUSTA ESTO SI EL COMANDO ES DIFERENTE!)
PROGRAMA_EJECUTABLE="zool"
# --- Fin Configuración ---


# 1. Verificar si 'wmctrl' existe.
if [ ! -f "$WMCTRL" ]; then
    echo "🚨 Error: La herramienta wmctrl no se encontró en $WMCTRL"
    exit 1
fi

# 2. Buscar la primera ventana que contenga el título.
# "$WMCTRL" -l -i : Lista todas las ventanas con sus IDs.
# grep "$TITULO_BUSCADO" : Filtra por la palabra "Zool".
# head -n 1 : Toma solo la primera coincidencia.
# awk '{print $1}' : Extrae el ID de la ventana (el primer campo).
WINDOW_ID=$("$WMCTRL" -l -i | grep "$TITULO_BUSCADO" | head -n 1 | awk '{print $1}')

# 3. Activar o Iniciar el programa
if [ -z "$WINDOW_ID" ]; then
    echo "🔍 No se encontró ninguna ventana con '$TITULO_BUSCADO' abierta."
    echo "Intentando iniciar el programa '$PROGRAMA_EJECUTABLE'..."
    
    # Intenta iniciar el programa. Usamos 'command -v' para buscar la ruta si no es absoluta.
    if command -v "$PROGRAMA_EJECUTABLE" &> /dev/null; then
        "$PROGRAMA_EJECUTABLE" &
    else
        echo "🚨 Advertencia: No se encontró el ejecutable '$PROGRAMA_EJECUTABLE' en su PATH."
    fi

else
    # Si se encontró la ventana, la activamos/enfocamos usando la ruta absoluta de wmctrl
    echo "✅ Activando ventana con título '$TITULO_BUSCADO' e ID: $WINDOW_ID"
    "$WMCTRL" -ia "$WINDOW_ID"
fi
