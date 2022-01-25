# Сборка и запуск регистратора quay

## Подключения субмодуля quay (исходный код quay)

Исходный код регистратора `quay` включен в репозиторий как субмодуль.
Для включения исходного кода после клонирования репозитория наберите команды наполнения поддиректория `dockerfiles/quayservices/quay` текущим исходным кодом:

```
$ git submodule init
Submodule 'quayservices/quay' (https://github.com/quay/quay) registered for path 'quay'
$ git submodule update
Cloning into '.../dockerfiles/quayservices/quay'...
Submodule path 'quay': checked out 'xxx...'
```

## Сборка образов quay, postgres, redis

В файле `.env` в переменной `regNS` укажите DNS-имя регистратора.
Например:
```
regNS=altlinux.io
```
DNS-имя должно быть зарегистрировано  как минимум в локальной сети на DNS-серверах.

Перейдите в каталог `dockerfiles/quayservices/` и вызовите скрипт
```
$ build.sh
```
Скрипт последовательно вызовет скрипты `build.sh` в каталогах 
`quay`, `postgres`, `redis` собирая соответствующие образы.
В случае приведенного DNS-имени регистратора `altlinux.io` создадутся образы:
```
altlinux.io/quay/quay
altlinux.io/quay/postgres
altlinux.io/quay/redis
```

## Запуск регистратора quay через docker-compose (минимальная конфигурация)

> Здесь и далее приведен пример разворачивания регистратора в кластере, описанном на странице 
> [ALT Container OS подветка K8S. Создание HA кластера](https://www.altlinux.org/ALT_Container_OS_подветка_K8S._Создание_HA_кластера)

Скрипты и YML-файла запуска регистратора в режиме `docker-compose` приведены в каталоге `/quayservices/docker-compose/' репозитория.

Запуск регистратора `quay` необходимо провести на одном из узлов кластера (`master` или `worker` не важно).
Для запуска узел должен иметь не менее `6GB` оперативной памяти и не менее `20GB` дисковой.

В данном примере образы имеют префикс `altlinux.io`. Необходимо для данного домена в DNS сервере
прописать данный домен с IP-адресом узла на котором будет разворачиваться регистратор `quay`.
YML-файл [docker-compose.yml](docker-compose.yml) описания сервисов выглядит следующим образом:
```
version: '3.2'

services:
  quay:
    image: ${regNS}/quay/quay
    #command: config Htubcnhfnjh
    volumes:
      - quay_config:/quay-registry/conf/stack
      - quay_datastorage:/datastorage
    ports:
      - ${HTTPPORT}:8080
      - ${HTTPSPORT}:8443

  quayredis:
    image: ${regNS}/quay/redis
    volumes:
      - quay_redis_data:/data

  quaydb:
    image: ${regNS}/quay/postgres
    volumes:
      - quay_postgres_data:/var/lib/pgsql/data

volumes:
  quay_config:
  quay_datastorage:
  quay_redis_data:
  quay_postgres_data:
```
Переменные `regNS`, `HTTPPORT`, `HTTPSPORT` импортируются из файла `.env`:
```
regNS=altlinux.io
commitId=162b79ec
HTTPPORT=80
HTTPSPORT=443
``` 
Запуск `docker-compose.yml` скриптом `start.sh`:
```
docker-compose  -p QUAY up -d
```

При запуске создаются три сервиса:
- `quayredis` - redis-хранилище ключ-значение с именованым томом  `quay_redis_data` монтируемый в каталог `/data`;
- `quaydb` - postges-сервер с именованым томом `quay_postgres_data` монтируемый в каталог `/var/lib/pgsql/data`;
- `quay` - регистратор `quay` доступный по внешним портам `80`, `443` с именоваными томами:
  * `quay_config` монтируемый в каталог `/quay-registry/conf/stack`;
  * `quay_datastorage` монтируемый в каталог `/datastorage`.

### Конфигурация параметров сервера

Перейдите в каталог `quayservices/` и раскомментируйте в файле `docker-compose.yml` строку 
```
    command: config Htubcnhfnjh
``` 
Запустите сервисы скриптом `start.sh`.

В браузере обратитесь по URL `http://<DNS-регистратора>/` (В нашем случае `http://altlinux.io/`).
> Если порт `80` занят укажите другую привязку порта `8080` в файле `docker-compose.yml` (например `18080`) и укажите порт в URL `http://altlinux.io:18080/`  

Для авторизации укажите имя входа `quayconfig` и пароль, указанный после параметра `config` а раскомментированной строке (`Htubcnhfnjh`).

В разделе `Server configuration` укажите dns имя сервиса (например `altlinux.io`).
DNS-имя должно быть зарегистрировано  как минимум в локальной сети на DNS-серверах.
![](./Images/quaySet.png)

В разделе `Database` выберите тип базы `Postgres` и введите указанные значения. Укажите пароль `Htubcnhfnjh`. 
![](./Images/postgresSet.png)
> `Database Server` берётся из имени сервиса `postgres` в `docker-compose.yml`. Значения остальных  параметров задаются в файле `postgres/Dockerfile`. 

В разделе `Redis` укажите имя сервиса `quayredis` (имя сервиса redis в `docker-compose.yml`):
![](./Images/redisSet.png)

После ввода минимально необходимых параметров нажмите на появившейся внизу клавише `Validate Configuration Changes`. В случае корректного ввода параметов во всплывающем окне появится надпись `Configuration Validated`: 
![](./Images/validateConfig.png)

Нажмите на клавишу `Download` и загрузите tar-архив конфигурации на локальный компьютер (обычно в `~/Загрузки/quay-config.tar.gz`)

### Запуск quay в минимальном варианте

Остановите стек сервисов:
```
$ stop.sh
```

Под суперпользователем перейдите в каталог:
```
# cd /var/lib/docker/volumes/quay_quay_config/_data
```

Разархивируйте файл конфигурации:
```
# tar xvzf .../quay-config.tar.gz
```

Вернитесь в каталог `dockerfiles/quayservices`, закомментируйте в
`docker-compose.yml` строку 
```
    #command: config Htubcnhfnjh
``` 
и запустите сервисы скриптом `start.sh`.

### Добавление пользователей

В браузере обратитесь по URL `http://altlinux.io/`.
> Если порт `80` занят укажите другую привязку порта `8080` в файле `docker-compose.yml` (например `18080`) 
> и укажите порт в URL `http://altlinux.io:18080/`  

Кликните клавишу `Create Account`:
![](./Images/createAccount.png)

Задайте необходимые параметры входа:
![](./Images/defineAccount.png)

Кликните по клавише `Create Account`. Отобразится начальное окно интерфейса:
![](./Images/listRepos.png)

#### Размещение образов в репозитории

Зарегистрируйтесь в репозитории:
```
# podman login --tls-verify=false altlinux.io 
Username: quay
Password: xxxx
Login Succeeded!
```

> Если Вы планируете работать с клиентом `docker` через `docker daemon` флаг `--tls-verify=false` не используется.
> Для работы по протоколу `http` добавьте флаг `--insecure-registry altlinux.io` в файл опций `/etc/sysconfig/docker` 
> или в файл `/etc/docker/daemon.json` и перезапустите `docker daemon`.

Разместите в репозитории созданные образы:
```
# podman push --tls-verify=false altlinux.io/quay/quay 
...
Writing manifest to image destitation
Storing signatures

# podman push --tls-verify=false altlinux.io/quay/postgres 
...
Writing manifest to image destitation
Storing signatures

# podman push --tls-verify=false altlinux.io/quay/redis 
...
Writing manifest to image destitation
Storing signatures

```
Перегрузите страницу списка репозиториев:
![](./Images/listFilledRepos.png)

#### Перевод размещенных репозиториев в статус `Публичные`

Последовательно зайдите в размещенные репозитории, кликните клавишу `Settings` (слева внизу)
и переведите репозитории в статус `Публичные`:
![](./Images/make_public.png)


## Запуск регистратора quay в kubernetes (минимальная конфигурация)

Скрипты и YML-файла запуска регистратора в режиме `` приведены в каталоге `/quayservices/k8s/' репозитория.


### Предварительный настройки

#### Настройка DNS регистратора

Как описано выше, необходимо на узлах кластера прописать DNS-сервер, который по домену `altlinux.io` будет 
возвращать `IP-адрес` узла где развернут вышеописанный регистратор в режиме `docker-compose`.
После подъема регистратора в режиме `kubernetes` домен `altlinux.io` будет перепривязан  

#### Требования к узлам

На узлах, где возможен запуск образа регистратора `altlinux.io/quay/quay` (возможно с репликами) необходимо наличние не менее `6GB` оперативной памяти и `20GB` дисковой. 
На узлах, где будет запущен образ базы данных `altlinux.io/quay/postgres` необходимо наличие не менее `20GB` дисковой памяти. 
Образ `altlinux.io/quay/redis` не предъявляет особенных требований.

#### Настройка файла /etc/containers/registries.conf конфигурации регистраторов

Для работы с регистратором по локальной сети в режиме `insecure` (по протоколу `http`) в файле
`/etc/containers/registries.conf`  на всех узлах раскоментируйте описатель `[[registry]]` и добавьте нижеприведенные строки:

```
[[registry]]
location = "altlinux.io"
insecure = true
```

Кроме этого можно добавить домен `altlinux.io` в описатель `unqualified-search-registries`:
```
unqualified-search-registries = ['altlinux.io', 'docker.io', 'registry.fedoraproject.org', 'registry.access.redhat.com', 'registry.centos.org']
```

После корректировки необходимо рестартовать сервисы `podman` и `crio`:
```
systemctl restart podman
systemctl restart crio
```
или перегрузить систему.

### Запуск сервисов

#### Создание namespace quay

Для удобства работы все `kubernetes-ресурсы` будут создавать в `namespace` `quay`.
Для этого необходимо создать данный `namespace`:
```
kubectl create ns quay
```

#### Создание сервиса базы данных postgres

Так как в данном развертывании не используются внешние сетевые тома, то для базы данных в каталоге `/var/lib/pgsql/` (как и в случае `docker-compose`) 
необходимо использовать локальный том (каталог) на одном из узлов.
В данном случае используем тома типа `hostPath`.
Опишем манифесты типа `PersistentVolume` (описание доступных томов) и PersistentVolumeClaim (запрос на том) в файле
`postgres/storage.yaml`:
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: pg-pv-volume
  labels:
    type: local
    app: postgres
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/var/lib/quaypostgres"
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker03 
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: postgres-pv-claim
  namespace: quay
  labels:
    quay-component: postgres          
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```
Манифест `PersistentVolume` описывает ресурс `pg-pv-volume` - каталог `/var/lib/quaypostgres` на узле `worker03`.
По параметрам он удовлетворяет запросу `postgres-pv-claim`.

Для инициализации необходимых пользователей и баз в файле `postgres/configmap.yaml` 
сформирован манифест `ConfigMap` с именем `postgres-config` :
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgres-config
  namespace: quay
  labels:
    quay-component: postgres
data:
  POSTGRES_DB: registry
  POSTGRES_USER: quayuser
  POSTGRES_PASSWORD: Htubcnhfnjh
```
`ConfigMap` обеспечивает экспорт переменных `POSTGRES_DB`, `POSTGRES_USER`, `POSTGRES_PASSWORD`
в среду запускаемого контейнера. Если в момент запуска база данных (каталог `/var/lib/quaypostgres`)
пуста, в базе данных создается указанный пользователь и база данных. 

Манифест разворачивния `postgres` описан в файле
`postgres/deployment.yaml`:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: postgres
  namespace: quay
  labels:
    quay-component: postgres
spec:
  replicas: 1
  selector:
    matchLabels:
      quay-component: postgres
  template:
    metadata:
      labels:
        quay-component: postgres
    spec:
      containers:
        - name: postgres
          image: altlinux.io/quay/postgres
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 5432
          envFrom:
            - configMapRef:
                name: postgres-config
          volumeMounts:
            - mountPath: /var/lib/pgsql/data
              name: postgredb
      volumes:
        - name: postgredb
          persistentVolumeClaim:
            claimName: postgres-pv-claim
```
Манифест `postgres` с меткой `quay-component=postgres` запускает образ `altlinux.io/quay/postgres`
на узле `worker03` с томом, удовлетворяющий запросу `claimName=postgres-pv-claim` смонтированным на каталог `/var/lib/pgsql/data`. 
Образу при запуске будут передаваться переменные, описанные в `configMap` с именем `postgres-config`.

Для поддержки DNS-имени `quaydb` в файле `postgres/service.yaml` описан `ClusterIP`-сервис,
привязывающий `POD` с меткой `quay-component=postgres` и портом `5432` к DNS имени `quaydb`:
```
apiVersion: v1
kind: Service
metadata:
  namespace: quay
  name: quaydb
  labels:
    quay-component: postgres
spec:
  ports:
    - port: 5432
      targetPort: 5432
  selector:
    quay-component: postgres
```

Все описанные манифесты располагаются в каталоге `postgres` и запускаются командой
```
kubectl apply -f postgres/
```
После запуска проверьте выделение томов командами:
```
# kubectl get persistentvolumes -o wide
NAME              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE    VOLUMEMODE
pg-pv-volume      10Gi       RWX            Retain           Bound    quay/postgres-pv-claim   manual                  3h4m   Filesystem
[root@master01 quay]# kubectl get persistentvolumeclaims -n quay -o wide
NAME                STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE    VOLUMEMODE
postgres-pv-claim   Bound    pg-pv-volume      10Gi       RWX            manual         3h4m   Filesystem
```
Статус обоих манифестов должен быть `Bound`.

После загрузки и запуска образа `altlinux.io/quay/postgres` состояние ресурсов в `namespace` `quay` должно быть следующим:
```
# kubectl get all -o wide -n quay  
NAME                            READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
pod/postgres-5cd7f757d6-4mhrq   1/1     Running   0          30s   10.244.4.3   worker03   <none>           <none>

NAME             TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/quaydb   ClusterIP   10.103.178.83   <none>        5432/TCP   30s   quay-component=postgres

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
deployment.apps/postgres   1/1     1            1           30s   postgres     altlinux.io/quay/postgres   quay-component=postgres

NAME                                  DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                      SELECTOR
replicaset.apps/postgres-5cd7f757d6   1         1         1       30s   postgres     altlinux.io/quay/postgres   pod-template-hash=5cd7f757d6,quay-component=postgres
```

#### Создание сервиса хранилища ключ-значение redis

Так как в данном развертывании не используются внешние сетевые тома, то для хранилища ключ-значение в каталоге `/data/` 
(как и в случае `docker-compose`) необходимо использовать локальный том (каталог) на одном из узлов.
В данном случае используем тома типа `hostPath`.
Опишем манифесты типа `PersistentVolume` (описание доступных томов) и `PersistentVolumeClaim` (запрос на том) в файле
`redis/storage.yaml`:
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: redis-pv-volume
  labels:
    type: local
    app: redis
spec:
  storageClassName: manual
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/var/lib/quayredis/data"
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker02 
    
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: redis-pv-claim
  namespace: quay
  labels:
    quay-component: redis          
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 10Gi
```      
Манифест `PersistentVolume` описывает ресурс `redis-pv-volume` - каталог `/var/lib/quayredis/data/` на узле `worker03`.
По параметрам он удовлетворяет запросу `redis-pv-claim`.

Манифест разворачивния `redis` описан в файле `redis/deployment.yaml`:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis 
  namespace: quay
  labels:
    quay-component: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      quay-component: redis
  template:
    metadata:
      labels:
        quay-component: redis
    spec:
      containers:
        - name: redis
          image: altlinux.io/quay/redis
          imagePullPolicy: "IfNotPresent"
          ports:
            - containerPort: 6379
          volumeMounts:
            - mountPath: /data
              name: redisdb
      volumes:
        - name: redisdb
          persistentVolumeClaim:
            claimName: redis-pv-claim
```
Манифест `redis` с меткой `quay-component=redis` запускает образ `altlinux.io/quay/redis`
на узле `worker02` с томом, удовлетворяющий запросу `claimName=redis-pv-claim` смонтированным на каталог `/data`. 

Для поддержки DNS-имени `quayredis` в файле `redis/service.yaml` описан `ClusterIP`-сервис,
привязывающий `POD` с меткой `quay-component=redis` и портом `6379` к DNS имени `quayredis`:
```
apiVersion: v1
kind: Service
metadata:
  namespace: quay
  name: quayredis
  labels:
    quay-component: redis
spec:
  ports:
    - port: 6379
      targetPort: 6379
  selector:
    quay-component: redis
```

Все описанные манифесты располагаются в каталоге `redis/` и запускаются командой
```
kubectl apply -f redis/
```
После запуска проверьте выделение томов командами:
```
# kubectl get persistentvolumes -o wide
NAME              CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                    STORAGECLASS   REASON   AGE    VOLUMEMODE
...
redis-pv-volume   10Gi       RWX            Retain           Bound    quay/redis-pv-claim      manual                  112m   Filesystem
[root@master01 quay]# kubectl get persistentvolumeclaims -n quay -o wide
NAME                STATUS   VOLUME            CAPACITY   ACCESS MODES   STORAGECLASS   AGE    VOLUMEMODE
...
redis-pv-claim      Bound    redis-pv-volume   10Gi       RWX            manual         112m   Filesystem
```
Статус обоих манифестов должен быть `Bound`.

После загрузки и запуска образа `altlinux.io/quay/redis` состояние ресурсов в `namespace` `quay` должно быть следующим:
```
# kubectl get all -o wide -n quay  
NAME                            READY   STATUS    RESTARTS   AGE   IP           NODE       NOMINATED NODE   READINESS GATES
pod/postgres-5cd7f757d6-4mhrq   1/1     Running   0          72m   10.244.4.3   worker03   <none>           <none>
pod/redis-855ccddfd-6s5zd       1/1     Running   0          8s    10.244.5.3   worker02   <none>           <none>

NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE   SELECTOR
service/quaydb      ClusterIP   10.103.178.83   <none>        5432/TCP   72m   quay-component=postgres
service/quayredis   ClusterIP   10.103.37.60    <none>        6379/TCP   8s    quay-component=redis

NAME                       READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
deployment.apps/postgres   1/1     1            1           72m   postgres     altlinux.io/quay/postgres   quay-component=postgres
deployment.apps/redis      1/1     1            1           8s    redis        altlinux.io/quay/redis      quay-component=redis

NAME                                  DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                      SELECTOR
replicaset.apps/postgres-5cd7f757d6   1         1         1       72m   postgres     altlinux.io/quay/postgres   pod-template-hash=5cd7f757d6,quay-component=postgres
replicaset.apps/redis-855ccddfd       1         1         1       8s    redis        altlinux.io/quay/redis      pod-template-hash=855ccddfd,quay-component=redis
```

#### Запуск регистратора в режиме конфигурации

При запуске регистратора в режиме конфигурации в физических томах нет необходимости. 
Поэтому манифесты типа `PersistentVolume` и `PersistentVolumeClaim` не требуются. 
Манифест разворачивния `quay-config` описан в файле `quay-config/deployment.yaml`:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: quay
  name: quay-config-app
  labels:
    quay-component: config-app
spec:
  replicas: 1
  selector:
    matchLabels:
      quay-component: config-app
  template:
    metadata:
      namespace: quay
      labels:
        quay-component: config-app
    spec:
      containers:
      - name: quay-config-app
        image: altlinux.io/quay/quay 
        ports:
        - containerPort: 8080
        - containerPort: 8443
        command: ["/quay-registry/quay-entrypoint.sh"]
        args: ["config", "Htubcnhfnjh"]
```
При запуске стартовому скрипту контейнера передаются параметры `config Htubcnhfnjh`.
В этом режиме регистратор поддерживает интерфейс конфигурации, описанный выше.

Для обеспечения доступа к регистратору извне из WEB-браузера в файле `quay-config/service-nodeport.yaml` описывается сервис типа `NodePort`:
```
apiVersion: v1
kind: Service
metadata:
  name: quay-config-service-np
  namespace: quay
spec:
  ports:
  - port: 8080
    targetPort: 8080
  selector:
    quay-component: config-app
  type: NodePort
```
Сервис обеспечивает выделение на master-узлах порта в диапазоне ` 30000-32767` и его проброс на порт
`8080` `POD`а регистратора.


Все описанные манифесты располагаются в каталоге `quay-config/` и запускаются командой
```
kubectl apply -f quay-config/
```
Узнать номер выделенного порта можно командой:
```
# kubectl get svc -o wide -n quay  | grep quay-config-service-np
quay-config-service-np   NodePort    10.102.8.32     <none>        8080:31945/TCP   31m    quay-component=config-app
```
Для конфигурации регистратора наберите в WEB-браузере `URL`: `http:<master_IP>:31945.
Где `<master_IP>` - IP-адрес одного из master-узлов.

Процесс конфигурирования описан выше в разделе запуска регистратора в `docker-compose`-режиме.
После конфигурирования скачайте архив конфигурации `quay-config.tar.gz`.

Удалите ресурсы `quay-config` командой:
```
kubectl delete -f quay-config/
```

#### Запуск сконфигурированного регистратора

Разавхивируйте полученный архив и поместите содержимое файла `config.yaml` в файл-манифест `quay/quay-configmap.yaml`: 
```
apiVersion: v1
kind: ConfigMap
metadata:
  name: quay-config
  namespace: quay
data:
  config.yaml: |
    AUTHENTICATION_TYPE: Database
    AVATAR_KIND: local
    BUILDLOGS_REDIS:
        host: quayredis
        port: 6379
    DATABASE_SECRET_KEY: 0882a0a3-a6a4-4bcc-b57b-4d68bf3d63d4
    DB_CONNECTION_ARGS: {}
    DB_URI: postgresql://quayuser:Htubcnhfnjh@quaydb/registry
    DEFAULT_TAG_EXPIRATION: 2w
    DISTRIBUTED_STORAGE_CONFIG:
        default:
            - LocalStorage
            - storage_path: /datastorage/registry
    ...
```

Регистратор хранит слои и метаинформацию по образам в каталоге `/datastorage/`.
Так как в данном развертывании не используются внешние сетевые тома, то для каталога `/datastorage/` 
(как и в случае `docker-compose`) необходимо использовать локальный том (каталог) на одном из узлов.
В данном случае используем тома типа `hostPath`.
Опишем манифесты типа `PersistentVolume` и `PersistentVolumeClaim` в файле
`quay/storage.yaml`:
```
kind: PersistentVolume
apiVersion: v1
metadata:
  name: quay-pv-volume
  labels:
    type: local
    app: quay
spec:
  storageClassName: manual
  capacity:
    storage: 30Gi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/var/lib/quaystorage/"
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - worker01 
    
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: quay-pv-claim
  namespace: quay
  labels:
    quay-component: quay          
spec:
  storageClassName: manual
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 30Gi
```
> В режиме `production` для хранения множества образов размер необходимой дисковой памяти необходимо увеличить. 

Для запуска регистратора создадим файл-манифест `quay/deployment.yaml`:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  namespace: quay
  name: quay-app
  labels:
    quay-component: quay-app
spec:
  replicas: 1
  selector:
    matchLabels:
      quay-component: quay-app
  template:
    metadata:
      namespace: quay
      labels:
        quay-component: quay-app
    spec:
      containers:
      - name: quay-app
        image: altlinux.io/quay/quay 
        ports:
        - containerPort: 8080
        - containerPort: 8443
        volumeMounts:
        - name: config
          mountPath: /quay-registry/conf/stack/
        - name: datastorage
          mountPath: /datastorage/ 
      volumes:
      - name: config
        configMap:
          name: quay-config
      - name: datastorage
        persistentVolumeClaim:
          claimName: quay-pv-claim
```
> Так как регистратор запускается от имени непривелигированного пользователя `default` после запуска 
> регистратора не измените права доступа директория `/var/lib/quaystorage/`:
> `chmod 777 /var/lib/quaystorage/`.

Для обеспечения доступа к регистратору извне из WEB-браузера в файле `quay/service-nodeport.yaml` описывается сервис типа `NodePort`:
```
apiVersion: v1
kind: Service
metadata:
  name: quay-service
  namespace: quay
spec:
  ports:
  - port: 8080
    targetPort: 8080
    nodePort: 31000
  selector:
    quay-component: quay-app
  type: NodePort
```
Сервис обеспечивает выделение на master-узлах порта ` 31000` и его проброс на порт
`8080` `POD`а регистратора.

Все описанные манифесты располагаются в каталоге `quay/` и запускаются командой
```
kubectl apply -f quay/
```
#### Настройка Loadbalncer'а

В качестве балансировщика нагрузки для доступа с регистратору используется балансировщик 
API-интерфейсов master-узлов, описанных на странице 
[ALT Container OS подветка K8S. Создание HA кластера](https://www.altlinux.org/ALT_Container_OS_подветка_K8S._Создание_HA_кластера).

В файл конфигурации `/etc/haproxy/haproxy.conf` добавим `frontend` и `backend` для регистратора на порту `31000` 
на мастер-узлах:
```
frontend registerhttp
    bind *:80
    mode tcp
    option tcplog
    default_backend registerhttp
backend registerhttp
    option httpchk GET /
    http-check expect status 200
    mode tcp
    balance     roundrobin
        server master01 10.150.0.161:31000 check
        server master02 10.150.0.162:31000 check
        server master03 10.150.0.163:31000 check
```

После перезапуска сервиса `haproxy`:
```
systemctl restart haproxy
```
необходимо на DNS-сервере поменять привязку домена `altlinux.io` на IP-адрес одного из балансировщиков. 




## Ссылки

- [How to manage Linux container registries](https://www.redhat.com/sysadmin/manage-container-registries)


