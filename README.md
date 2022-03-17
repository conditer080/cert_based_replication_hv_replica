RUS:

system req: windows 2016 + server on both h-v host and replica host

Скрипт позвляет подружить hyper-v host и hyper-v replica средствами сертификатов.

1) запускаем от админа скрипт hv_replica_selfsign.cmd на Hyper-v HOST 

2) вводим имя сервера replica

3) вводим любой пароль для выгрузки сертификатов

4) получаем на рабочем столе папку TO_REPLICA_SERVER

5) копируем папку TO_REPLICA_SERVER на сервер replica

6) на сервере replica запускаем от имени админа скрипт RUN_on_REPLICA_ONLY.cmd

7) запускам репликацию

8) Profit


ENG:

system requirement: Windows 2016 + server on both h-v host and replica host

The script allows you to make friends between a Hyper-V host and a Hyper-V replica using certificates.

1) run the script hv_replica_selfsign.cmd with Administrator rights on the Hyper-v HOST

2) enter the name of the replica server

3) enter any password to import/export certificates

4) you will get TO_REPLICA_SERVER folder on the desktop  

5) copy TO_REPLICA_SERVER folder to the server replica

6) on the REPLICA server run script RUN_on_REPLICA_ONLY.cmd with admins rights

7) start replication

8) Profit

