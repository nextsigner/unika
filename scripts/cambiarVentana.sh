#!/bin/bash

# Este script simula el atajo Alt Izquierdo + Tab para cambiar de ventana usando xdotool.

# 1. Asegúrate de que 'xdotool' está instalado:
#    Si no lo está, puedes instalarlo con: sudo apt install xdotool

# 2. Simula la pulsación de la tecla Alt izquierda (Alt_L)
xdotool keydown Alt_L

# 3. Simula la pulsación y liberación de la tecla Tab
#    Esto es lo que activa el cambio de ventana.
xdotool key Tab

# 4. Simula la liberación de la tecla Alt izquierda
xdotool keyup Alt_L

exit 0
