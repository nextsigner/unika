#!/bin/bash

# --- PASO 1: Abrir MATE Terminal ---
mate-terminal &

# Guarda el ID del proceso (PID) de la terminal
MATE_PID=$!

# Espera un momento para asegurar que la ventana se haya creado
# 1 segundo es a menudo suficiente, pero puedes ajustarlo.
sleep 3


# Escribe el texto 'ls'
xdotool type "ls"

# Presiona la tecla Enter para ejecutar el comando
xdotool key "Return"

echo "Comando 'ls' ejecutado."
