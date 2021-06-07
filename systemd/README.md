**1. Создать сервис и unit-файлы для этого сервиса:**
- сервис: bash, python или другой скрипт, который мониторит log-файл на наличие ключевого слова;
- ключевое слово и путь к log-файлу должны браться из /etc/sysconfig/ (.service);
- сервис должен активироваться раз в 30 секунд (.timer).
```
[vagrant@systemd ~]$ sudo -i
```
Создаем для нашего сервиса конфиг-файл следующего содержания:
```
[root@systemd ~]# cat /etc/sysconfig/watchlog
#Config file for my watchlog service

#WORD for find in file LOG
WORD="ALERT"
LOG=/var/log/watchlog.log
```
Создаем лог-файл по пути `/var/log/watchlog.log`, заполняем его рандомными строками, а также словом "ALERT".

Создаем скрипт `/opt/watchlog.sh` для будущего сервиса:
```
[root@systemd ~]# cat /opt/watchlog.sh
#!/bin/bash

WORD=$1
LOG=$2
DATE=$(date)

if grep $WORD $LOG &> /dev/null;then
#logger - enter messages into the system log
	logger "$DATE: I found word, Master!"
else
	exit 0
fi

[root@systemd ~]# chmod +x /opt/watchlog.sh
```
Создаем service unit:
```
[root@systemd ~]# cat /etc/systemd/system/watchlog.service
[Unit]
Description=My wathlog service

[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchlog
ExecStart=/opt/watchlog.sh $WORD $LOG
```
Создаем timer unit. Для максимальной точности срабатывания таймера добавляем параметр `AccuracySec` со значением `1us`:
```
[root@systemd ~]# cat /etc/systemd/system/watchlog.timer
[Unit]
Description=Run watchlog script every 30 second

[Timer]
#Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
AccuracySec=1us

[Install]
WantedBy=multi-user.target
```
Запустим сервис, таймер и проверим результат:
```
[root@systemd ~]# systemctl daemon-reload
[root@systemd ~]# systemctl start watchlog.service
[root@systemd ~]# systemctl start watchlog.timer
[root@systemd ~]# tail -f /var/log/messages
Jun  7 08:29:57 localhost systemd: Removed slice User Slice of vagrant.
Jun  7 08:30:20 localhost systemd: Starting My wathlog service...
Jun  7 08:30:20 localhost root: Mon Jun  7 08:30:20 UTC 2021: I found word, Master!
Jun  7 08:30:20 localhost systemd: Started My wathlog service.
Jun  7 08:30:35 localhost systemd: Created slice User Slice of vagrant.
Jun  7 08:30:35 localhost systemd-logind: New session 3 of user vagrant.
Jun  7 08:30:35 localhost systemd: Started Session 3 of user vagrant.
Jun  7 08:30:50 localhost root: Mon Jun  7 08:30:50 UTC 2021: I found word, Master!
```
**2. Дополнить unit-файл сервиса httpd возможностью запустить несколько экземпляров сервиса с разными конфигурационными файлами.**

Для выполнения этого задания дополним unit-файл apache httpd возможностью запустить несколько инстансов сервера с разными конфигами.
```
[root@systemd ~]# yum install httpd -y
```
Создаем следующий шаблон для httpd сервиса:
```
[root@systemd ~]# cat /etc/systemd/system/httpd@.service
[Unit]
Description=The Apache HTTP Server
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)

[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true

[Install]
WantedBy=multi-user.target
```
В двух файлах окружения (для двух экземпляров сервиса httpd) зададим опцию для запуска веб-сервера с необходимым конфигурационным файлом:
```
[root@systemd ~]# cat /etc/sysconfig/httpd-first
OPTIONS=-f conf/first.conf
[root@systemd ~]# cat /etc/sysconfig/httpd-second 
OPTIONS=-f conf/second.conf
```
Соответственно в директории с конфигами httpd (`/etc/httpd/conf/`) должны лежать два конфига, в нашем случае это будут `first.conf` и `second.conf`. Для создания конфига `first.conf` просто скопируем оригинальный конфиг, а для `second.conf` поправим опции `PidFile` и `Listen`:
```
[root@systemd ~]# grep -E '^PidFile|^Listen' /etc/httpd/conf/second.conf
PidFile "/var/run/httpd-second.pid"
Listen 8008
```
Теперь можно запустить экземпляры сервиса:
```
[root@systemd ~]# systemctl start httpd@first
[root@systemd ~]# systemctl start httpd@second
```
Проверим порты:
```
[root@systemd ~]# ss -tnulp | grep httpd
tcp    LISTEN     0      128      :::8008                 :::*                   users:(("httpd",pid=7561,fd=4),("httpd",pid=7560,fd=4),("httpd",pid=7559,fd=4),("httpd",pid=7558,fd=4),("httpd",pid=7557,fd=4),("httpd",pid=7556,fd=4))
tcp    LISTEN     0      128      :::80                   :::*                   users:(("httpd",pid=7549,fd=4),("httpd",pid=7548,fd=4),("httpd",pid=7547,fd=4),("httpd",pid=7546,fd=4),("httpd",pid=7545,fd=4),("httpd",pid=7544,fd=4))
```
