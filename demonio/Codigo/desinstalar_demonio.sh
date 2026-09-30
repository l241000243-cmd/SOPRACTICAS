#!/bin/bash
# ============================================================
# desinstalar_demonio.sh
# Detiene y elimina el demonio en el orden correcto:
# primero se detiene y deshabilita, luego se borra la unidad
# y al final se recarga systemd (evita el aviso
# "unit file ... changed on disk").
# ============================================================

# 1. Detener el proceso
sudo systemctl stop mi-demonio

# 2. Quitarlo del arranque automatico
sudo systemctl disable mi-demonio

# 3. Borrar el archivo de la unidad
sudo rm -f /etc/systemd/system/mi-demonio.service

# 4. Recargar systemd para que olvide la unidad
sudo systemctl daemon-reload

# 5. Borrar el script y el archivo de mensajes
rm -f /home/hector/mi_demonio.sh /home/hector/mensaje_demonio.txt

# Comprobar: debe indicar que la unidad ya no existe
systemctl is-enabled mi-demonio 2>&1 || true
