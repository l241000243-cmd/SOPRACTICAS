# Capturas de pantalla

Guarda aquí las capturas (formato `.png` o `.jpg`), tomadas en tu propia terminal de Ubuntu:

1. `01_scripts.png` – `ls -l Codigo/` y `cat Codigo/salud_sistema.sh`
2. `02_permisos.png` – `chmod +x Codigo/*.sh` y `ls -l` con los permisos `x`
3. `03_instalar.png` – `./instalar_cron.sh` y `crontab -l` mostrando `*/2 * * * *`
4. `04_servicio_cron.png` – `systemctl status cron` (activo)
5. `05_log.png` – `cat ~/salud_sistema/salud_sistema.log` con varias mediciones cada 2 min
6. `06_syslog.png` – `grep CRON /var/log/syslog | tail` mostrando las ejecuciones
7. `07_carga.png` – el log después de abrir muchas pestañas o programas (RAM más alta)
