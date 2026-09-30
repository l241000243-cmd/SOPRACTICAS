#!/bin/bash
# ============================================================
# probar_reinicio.sh
# Mata el proceso del demonio para comprobar que systemd lo
# vuelve a levantar automaticamente (Restart=always).
# ============================================================

# PID actual del servicio antes de matarlo
echo "PID antes : $(systemctl show -p MainPID --value mi-demonio)"

# Terminar el proceso cuyo comando contiene mi_demonio.sh
sudo pkill -f mi_demonio.sh

# Dar tiempo a systemd para reiniciarlo
sleep 2

# El PID debe ser distinto: es un proceso nuevo
echo "PID despues: $(systemctl show -p MainPID --value mi-demonio)"

# El contador de reinicios aumenta cada vez que systemd lo relanza
systemctl show -p NRestarts mi-demonio

# Ultimos mensajes del servicio en el registro del sistema
journalctl -u mi-demonio -n 10 --no-pager
