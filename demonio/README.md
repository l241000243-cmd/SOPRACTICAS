# Práctica: Demonio – Servicio en segundo plano con systemd

## Objetivos
- Comprender qué es un **demonio** (*daemon*): un proceso que corre en segundo plano, sin terminal, y que el sistema operativo administra.
- Crear un script en Bash que se ejecute indefinidamente y registrar su actividad en la carpeta personal.
- Convertir ese script en un **servicio de systemd**: iniciarlo, habilitarlo en el arranque, consultar su estado y sus logs.
- Comprobar la **tolerancia a fallos** con `Restart=always`: si se mata el proceso, systemd lo levanta de nuevo.
- Detener y desinstalar el servicio de forma limpia.

## Estructura de carpetas
```
demonio/
├── README.md
├── Codigo/
│   ├── mi_demonio.sh           # Script que corre en bucle (escribe cada 5 s)
│   ├── mi-demonio.service      # Unidad de systemd
│   ├── instalar_demonio.sh     # Copia archivos, daemon-reload, enable --now
│   ├── probar_reinicio.sh      # Mata el proceso y verifica que systemd lo reinicia
│   └── desinstalar_demonio.sh  # stop, disable, rm, daemon-reload
├── Terminal/
│   ├── capturas/               # Capturas de la terminal
│   └── video/                  # Video demostrativo
└── Reporte/
    └── Reporte_Demonio.pdf     # Documento formal con análisis reflexivo
```

## Uso
```bash
cd demonio/Codigo
chmod +x *.sh
./instalar_demonio.sh             # crea e inicia el servicio
tail -f ~/mensaje_demonio.txt     # ver al demonio escribir cada 5 s (Ctrl+C para salir)
./probar_reinicio.sh              # matar el proceso y ver cómo systemd lo reinicia
journalctl -u mi-demonio -f       # log del servicio en vivo
./desinstalar_demonio.sh          # limpiar todo
```

## Explicación de comandos

| Comando | Para qué se usa |
|---|---|
| `cat > archivo <<'EOF' ... EOF` | Crea un archivo con el texto escrito (*here-document*). Con las comillas en `'EOF'`, `$(date)` se guarda literal y no se expande al crear el archivo. |
| `chmod +x` / `ls -l` | Da permiso de ejecución y lo verifica (`-rwxrwxr-x`). |
| `sudo tee /etc/systemd/system/mi-demonio.service > /dev/null` | Escribe la unidad en una carpeta del sistema con permisos de root. `tee` recibe el texto y `/dev/null` oculta el eco en pantalla. |
| `[Unit]`, `[Service]`, `[Install]` | Secciones de la unidad: descripción; usuario, programa y política de reinicio; cuándo se activa. |
| `Restart=always` | systemd relanza el proceso cada vez que termina. |
| `WantedBy=multi-user.target` | El servicio arranca junto con el sistema en modo multiusuario. |
| `sudo systemctl daemon-reload` | Hace que systemd vuelva a leer los archivos de unidades. |
| `sudo systemctl enable --now mi-demonio` | Crea el enlace simbólico en `multi-user.target.wants` (arranque automático) e inicia el servicio en ese momento. |
| `systemctl status mi-demonio` | Muestra el estado (`active (running)`), el PID principal, la memoria, el CPU y el árbol del *cgroup* (`bash` + `sleep`). |
| `tail -f ~/mensaje_demonio.txt` | Sigue en vivo las líneas que escribe el demonio. |
| `sudo pkill -f mi_demonio.sh` | Envía SIGTERM al proceso cuyo comando contiene ese texto. |
| `journalctl -u mi-demonio -f` | Log del servicio en el *journal* de systemd: arranques, desactivaciones y reinicios programados. |
| `systemctl stop` / `disable` | Detiene el proceso / quita el arranque automático. |
| `sudo rm ...service` + `daemon-reload` | Elimina la unidad y hace que systemd la olvide. |

## Evidencias
- `Terminal/capturas/01_creacion_y_arranque.jpg`:
  - creación de `mi_demonio.sh` y permisos `-rwxrwxr-x`;
  - creación de la unidad `mi-demonio.service` y `daemon-reload`;
  - `enable --now`, que crea el symlink en `multi-user.target.wants`;
  - `systemctl status`: `active (running)`, PID **17140**, 2 tareas, 2.6 MB de memoria y 62 ms de CPU.
- `Terminal/capturas/02_reinicio_journal_limpieza.jpg`:
  - `tail -f` muestra una línea cada 5 s (09:28:21 → 09:29:16);
  - después de `sudo pkill -f mi_demonio.sh`, `status` muestra un proceso nuevo con PID **17555**, iniciado a las 09:29:32;
  - `journalctl` registra `Deactivated successfully` → `Scheduled restart job, restart counter is at 1` → `Started`;
  - al final se ejecutan los comandos de limpieza.
- `Terminal/video/demo_demonio.mp4`: grabación de la práctica.

## Conclusiones técnicas
1. **Un demonio es un proceso ordinario al que administra el sistema.** Aquí es un `while true` en Bash. Lo que lo convierte en demonio es que systemd lo lanza sin terminal, con un usuario definido, lo coloca en su propio *cgroup* (`/system.slice/mi-demonio.service`) y lo vigila.
2. **`Restart=always` ofrece tolerancia a fallos.** Al matar el proceso, el PID cambió de 17140 a 17555 y el *journal* registró `restart counter is at 1`. El servicio se recuperó solo, en menos de un segundo, sin intervención del usuario.
3. **El proceso casi no consume recursos:** ~2–3 MB de RAM y 62–74 ms de CPU acumulados. Pasa casi todo el tiempo bloqueado en `sleep`, estado en el que el planificador no le asigna CPU. Por eso el *cgroup* muestra 2 tareas: `bash` y su hijo `sleep`.
4. **systemd distingue entre archivo de unidad y configuración cargada.** El aviso `unit file ... changed on disk` aparece cuando el archivo se modifica o se borra sin `daemon-reload`. El orden correcto para desinstalar es `stop` → `disable` → `rm` → `daemon-reload`, como en `desinstalar_demonio.sh`.
5. **`journalctl` centraliza los logs.** No hace falta que el script gestione su propio registro de errores: systemd guarda cada arranque, parada y reinicio con fecha y hora.
