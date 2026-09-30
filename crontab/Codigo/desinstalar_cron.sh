#!/bin/bash
# ============================================================
# desinstalar_cron.sh
# Quita del crontab la tarea de salud_sistema.sh sin borrar
# las demas tareas que tenga el usuario.
# ============================================================

# Filtrar todas las lineas excepto la de salud_sistema.sh y reinstalar el crontab
crontab -l 2>/dev/null | grep -v "salud_sistema.sh" | crontab -

echo "Tarea eliminada. Crontab actual:"
crontab -l
