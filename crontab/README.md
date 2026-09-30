# Práctica: Crontab – Monitor de salud del sistema

## Objetivos
- Automatizar una tarea en segundo plano con **cron**, el planificador de tareas de Linux.
- Registrar cada **2 minutos** el estado ("salud") de la computadora: RAM, swap, disco, carga del CPU y los procesos que más memoria consumen.
- Guardar el registro en la carpeta personal del usuario (`~/salud_sistema/salud_sistema.log`) para detectar cuándo navegadores, reproductores, editores y terminales saturan la RAM o el almacenamiento.
- Analizar el comportamiento del sistema operativo a partir de los datos recolectados.

## Estructura de carpetas
```
crontab/
├── README.md
├── Codigo/
│   ├── salud_sistema.sh      # Script de monitoreo (lo ejecuta cron)
│   ├── instalar_cron.sh      # Agrega la tarea al crontab (cada 2 min)
│   └── desinstalar_cron.sh   # Quita la tarea del crontab
├── Terminal/
│   ├── capturas/             # Capturas de pantalla de los comandos ejecutados
│   └── video/                # Video demostrativo (2 a 3 min)
└── Reporte/
    └── Reporte_Crontab.pdf   # Documento formal con análisis reflexivo
```

## Uso
```bash
cd crontab/Codigo
chmod +x *.sh
./instalar_cron.sh                              # instala la tarea */2 * * * *
crontab -l                                      # verifica la tarea
tail -f ~/salud_sistema/salud_sistema.log       # ve el registro en vivo
./desinstalar_cron.sh                           # cuando ya no se necesite
```

## Explicación de comandos

| Comando | Para qué se usa |
|---|---|
| `crontab -e` / `crontab -l` / `crontab -` | Editar, listar o reemplazar (desde la entrada estándar) las tareas programadas del usuario. |
| `*/2 * * * *` | Expresión de cron: minuto cada 2, cualquier hora, día, mes y día de la semana. |
| `systemctl status cron` | Verifica que el servicio (demonio) `cron` esté activo. |
| `grep CRON /var/log/syslog` | Muestra en el log del sistema cada vez que cron lanzó la tarea. |
| `free -m` | Memoria RAM y swap en MiB. Se usa la columna *available* para calcular el % real de uso. |
| `df -h "$HOME"` | Espacio del disco donde está la carpeta personal, en formato legible. |
| `/proc/loadavg` | Carga promedio del sistema a 1, 5 y 15 minutos (lo lee el kernel). |
| `uptime -p` | Tiempo que lleva encendida la computadora. |
| `ps -eo pid,comm,%mem,%cpu --sort=-%mem` | Lista los procesos ordenados por consumo de memoria. |
| `awk` | Extrae columnas específicas de la salida de `free` y `df`. |
| `mkdir -p` | Crea la carpeta de logs si no existe, sin error si ya existe. |
| `>>` | Agrega al final del archivo sin borrar lo anterior (historial). |
| `chmod +x` | Da permiso de ejecución a los scripts. |
| `tail -f` | Muestra el log en tiempo real conforme cron lo va escribiendo. |

### Detalles del script `salud_sistema.sh`
- Define `PATH` al inicio porque cron se ejecuta con un entorno mínimo y sin él podría no encontrar los comandos.
- Usa rutas absolutas y `$HOME`, ya que cron no abre una terminal ni carga `.bashrc`.
- Marca **ALERTA** cuando la RAM supera el 80 % o el disco el 85 %.

## Evidencias
- `Terminal/capturas/01_crontab_funcionando.jpg`: prueba de cron en la terminal (Konsole) de `hector@HP-Papas`:
  - se agrega una tarea `* * * * *` que escribe `Cron funcionando: $(date)` en `~/mensaje_cron.txt`;
  - se verifica con `crontab -l`;
  - con `cat` se ve que se ejecutó cada minuto (09:22 y 09:23);
  - al final se limpia con `crontab -r` y `rm`.
- `Terminal/video/demo_crontab.mp4`: grabación de esa misma prueba.

Esta prueba confirma que el demonio cron lanza tareas en segundo plano de forma periódica. Es el mismo mecanismo que usa `salud_sistema.sh` con la expresión `*/2 * * * *`.

## Conclusiones técnicas
1. **cron** es un demonio que despierta cada minuto, revisa las tablas de tareas y lanza las que coinciden con la hora. Así se automatiza el monitoreo sin dejar ningún proceso ocupando memoria entre ejecuciones (a diferencia de un `while true; sleep`).
2. El entorno de cron es diferente al de la terminal (PATH reducido, sin variables del usuario). Por eso los scripts programados deben ser autosuficientes y usar rutas absolutas.
3. Linux usa la RAM libre como caché de disco. Por eso la columna *used* de `free` no es el mejor indicador y se usa *available* para medir la presión real de memoria.
4. Con varias pestañas del navegador, reproductores y editores abiertos, el registro muestra cómo la RAM disponible baja, aparece uso de swap y sube la carga. Los procesos del navegador suelen encabezar el top de memoria.
5. Redirigir con `>>` genera un historial que permite comparar mediciones en el tiempo y detectar tendencias (por ejemplo, el disco llenándose poco a poco).
