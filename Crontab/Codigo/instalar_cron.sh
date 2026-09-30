#!/bin/bash
# ============================================================
# instalar_cron.sh
# Da permisos de ejecucion a salud_sistema.sh y agrega (una
# sola vez) la tarea al crontab del usuario para que se
# ejecute cada 2 minutos.
# ============================================================

# Ruta absoluta del script de monitoreo (misma carpeta que este archivo)
SCRIPT="$(cd "$(dirname "$0")" && pwd)/salud_sistema.sh"

# Linea de cron: minuto */2 = cada 2 minutos, resto de campos = siempre
TAREA="*/2 * * * * $SCRIPT"

# Permiso de ejecucion para el script
chmod +x "$SCRIPT"

# Si la tarea ya existe no se duplica; si no, se agrega al crontab actual
if crontab -l 2>/dev/null | grep -Fq "$SCRIPT"; then
    echo "La tarea ya estaba instalada:"
else
    ( crontab -l 2>/dev/null; echo "$TAREA" ) | crontab -
    echo "Tarea instalada:"
fi

# Mostrar el crontab final
crontab -l
