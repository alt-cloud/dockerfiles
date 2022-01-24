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
`quay`, `postgres`, `redis` собирая соответсвующие образы.
В случае приведенного DNS-имени регистратора `altlinux.io` создадутся образы:
```
altlinux.io/quay/quay
altlinux.io/quay/postgres
altlinux.io/quay/redis
```

## Запуск регистратора quay через docker-compose (минимальная конфигурация)

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
> Если порт `80` занят укахите другую привязку порта `8080` в файле `docker-compose.yml` (например `18080`) и укажите порт в URL `http://altlinux.io:18080/`  

Кликните клавишу `Create Account`:
![](./Images/createAccount.png)

Задайте необходимые параметры входа:
![](./Images/defineAccount.png)

Кликните по клавише `Create Account`. Отобразится начальное окно интерфейса:
![](./Images/listRepos.png)

#### Размещение образ в репозитории

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

## Запуск quay в kubernetes (минимальная конфигурация)

### Предварительный настройки

#### Настройка DNS регистратора




## Ссылки

- [How to manage Linux container registries](https://www.redhat.com/sysadmin/manage-container-registries)


