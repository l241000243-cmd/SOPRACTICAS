#!/bin/bash
# ============================================================
# instalar_demonio.sh
# Copia el script y la unidad a su lugar, recarga systemd y
# habilita + arranca el servicio. Ejecutar con: ./instalar_demonio.sh
# ============================================================

# Detener el script si algun comando falla
set -e

# Carpeta donde esta este instalador (y los demas archivos)
DIR="$(cd "$(dirname "$0")" && pwd)"

# 1. Copiar el script del demonio a la carpeta personal y hacerlo ejecutable
cp "$DIR/mi_demonio.sh" /home/hector/mi_demonio.sh
chmod +x /home/hector/mi_demonio.sh
ls -l /home/hector/mi_demonio.sh

# 2. Instalar la unidad de systemd (requiere sudo)
sudo cp "$DIR/mi-demonio.service" /etc/systemd/system/mi-demonio.service

# 3. Hacer que systemd lea la nueva unidad
sudo systemctl daemon-reload

# 4. Habilitar en el arranque (enable) e iniciar ahora mismo (--now)
sudo systemctl enable --now mi-demonio

# 5. Mostrar el estado del servicio
systemctl status mi-demonio --no-pager
