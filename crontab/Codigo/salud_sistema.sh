#!/bin/bash
# ============================================================
# salud_sistema.sh
# Registra la "salud" de la computadora (RAM, swap, disco,
# carga del CPU y procesos que mas memoria consumen) en un
# archivo de log dentro de la carpeta personal del usuario.
# Pensado para ejecutarse con cron cada 2 minutos.
# ============================================================

# cron ejecuta con un PATH minimo; lo definimos para encontrar los comandos
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Carpeta y archivo donde se guarda el registro
DIR_LOG="$HOME/salud_sistema"
ARCHIVO_LOG="$DIR_LOG/salud_sistema.log"

# Umbrales (en %) a partir de los cuales se marca una ALERTA
UMBRAL_RAM=80
UMBRAL_DISCO=85

# Crear la carpeta si no existe (-p evita error si ya esta)
mkdir -p "$DIR_LOG"

# ---------- Recoleccion de datos ----------

# Fecha y hora de la medicion
FECHA=$(date '+%Y-%m-%d %H:%M:%S')

# RAM: total, usada y disponible en MiB (fila "Mem:" de free -m)
read -r RAM_TOTAL RAM_USADA RAM_DISP < <(free -m | awk '/^Mem:/ {print $2, $3, $7}')
# Porcentaje de RAM usada = (total - disponible) / total
RAM_PCT=$(( (RAM_TOTAL - RAM_DISP) * 100 / RAM_TOTAL ))

# Swap: total y usada en MiB
read -r SWAP_TOTAL SWAP_USADA < <(free -m | awk '/^Swap:/ {print $2, $3}')

# Disco de la carpeta personal: tamano, usado, libre y % de uso
read -r DISCO_TAM DISCO_USADO DISCO_LIBRE DISCO_PCT < <(df -h "$HOME" | awk 'NR==2 {gsub("%","",$5); print $2, $3, $4, $5}')

# Carga promedio del sistema (1, 5 y 15 minutos)
CARGA=$(cut -d ' ' -f1-3 /proc/loadavg)

# Tiempo encendido
ENCENDIDO=$(uptime -p)

# Top 5 de procesos que mas RAM consumen
TOP_PROCESOS=$(ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 6)

# ---------- Escritura del registro ----------
{
    echo "==================== $FECHA ===================="
    echo "Encendido     : $ENCENDIDO"
    echo "Carga (1/5/15): $CARGA"
    echo "RAM           : ${RAM_USADA} MiB usados / ${RAM_TOTAL} MiB (${RAM_PCT}%) - disponible ${RAM_DISP} MiB"
    echo "Swap          : ${SWAP_USADA} MiB usados / ${SWAP_TOTAL} MiB"
    echo "Disco (\$HOME) : ${DISCO_USADO} usados / ${DISCO_TAM} (${DISCO_PCT}%) - libre ${DISCO_LIBRE}"

    # Alertas si se superan los umbrales
    if [ "$RAM_PCT" -ge "$UMBRAL_RAM" ]; then
        echo "ALERTA: la RAM supera el ${UMBRAL_RAM}% de uso"
    fi
    if [ "$DISCO_PCT" -ge "$UMBRAL_DISCO" ]; then
        echo "ALERTA: el disco supera el ${UMBRAL_DISCO}% de uso"
    fi

    echo "Procesos que mas memoria usan:"
    echo "$TOP_PROCESOS"
    echo
} >> "$ARCHIVO_LOG"
