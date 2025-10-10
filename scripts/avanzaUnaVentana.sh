#!/bin/bash
# 1. Presionar y mantener la tecla Alt Izquierdo (Alt_L)
xdotool keydown Alt_L
# 2. Presionar Tab
xdotool key Tab

# 3. Esperar 0.5 segundos (suficiente para que aparezca el menú del conmutador)
sleep 2.5

# 4. Pulsar la tecla Tab. Esto mueve la selección del conmutador a la PRÓXIMA ventana.
xdotool key Tab

sleep 2.5

# 5. Soltar la tecla Alt Izquierdo. Esto confirma el cambio a la ventana seleccionada.
xdotool keyup Alt_L

exit 0
