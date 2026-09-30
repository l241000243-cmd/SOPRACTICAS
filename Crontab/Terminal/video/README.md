# Video demostrativo (2 a 3 min)

Graba tu pantalla en Ubuntu con **Ctrl + Alt + Shift + R** (inicia y detiene la grabación; el video queda en `~/Vídeos/Screencasts`) o con OBS / SimpleScreenRecorder. Guárdalo aquí como `demo_crontab.mp4`.

Guion sugerido:
1. (0:00–0:30) Mostrar la carpeta `Codigo` y explicar brevemente `salud_sistema.sh`.
2. (0:30–1:00) Ejecutar `./instalar_cron.sh` y `crontab -l`; explicar `*/2 * * * *`.
3. (1:00–1:30) `systemctl status cron` y `grep CRON /var/log/syslog | tail`.
4. (1:30–2:30) Abrir varias pestañas en Firefox y dejar `tail -f ~/salud_sistema/salud_sistema.log` hasta que aparezca una nueva medición con más RAM usada.
5. (2:30–3:00) Conclusión y `./desinstalar_cron.sh`.
