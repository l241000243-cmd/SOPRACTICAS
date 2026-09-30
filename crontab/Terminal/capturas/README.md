# Capturas de pantalla

- `01_crontab_funcionando.jpg`: se agrega una tarea al crontab, se lista con `crontab -l`, se muestra la salida escrita cada minuto (`cat ~/mensaje_cron.txt`) y se limpia con `crontab -r`.

Capturas sugeridas para completar la evidencia del monitor de salud:
- `./instalar_cron.sh` y `crontab -l` mostrando `*/2 * * * *`
- `systemctl status cron`
- `cat ~/salud_sistema/salud_sistema.log` con varias mediciones
