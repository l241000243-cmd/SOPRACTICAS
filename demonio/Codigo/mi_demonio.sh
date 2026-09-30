#!/bin/bash
# ============================================================
# mi_demonio.sh
# Proceso que se ejecuta indefinidamente en segundo plano.
# Cada 5 segundos agrega una linea con la fecha y hora al
# archivo ~/mensaje_demonio.txt para demostrar que sigue vivo.
# systemd lo lanza y lo vigila mediante mi-demonio.service.
# ============================================================

# Archivo donde el demonio deja constancia de que esta funcionando
ARCHIVO="/home/hector/mensaje_demonio.txt"

# Bucle infinito: un demonio no termina por si solo
while true; do
    # >> agrega al final sin borrar lo anterior
    echo "Demonio funcionando: $(date)" >> "$ARCHIVO"
    # Duerme 5 s; mientras tanto el proceso no consume CPU
    sleep 5
done
