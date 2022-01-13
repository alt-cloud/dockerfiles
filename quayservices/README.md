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

Перейдите в каталог `dockerfiles/quayservices/` и вызовите скрипт
```
$ build.sh
```
Скрипт последовательно вызовет скрипты `build.sh` в каталогах 
`quay`, `postgres`, `redis` собирая соответсвующие образы.

## Минимальные действия для конфигурации и запуску quay в docker-compose

Перейдите в каталог `quayservices/` и раскомментируйте в файле `docker-compose.yml` строку 
```
    command: config Htubcnhfnjh
``` 
Запустите сервисы скриптом `start.sh`.

В браузере обратитесь по URL `http://localhost/`.
> Если порт `80` занят укахите другую привязку порта `8080` в файле `docker-compose.yml` (например `18080`) и укажите порт в URL `http://localhost:18080/`  

Для авторизации укажите имя входа `quayconfig` и пароль, указанный после параметра `config` а раскомментированной строке (`Htubcnhfnjh`).

В разделе `Server configuration` укажите имя сервиса (`quay`).
![](./Images/quaySet.png)

В разделе `Database` выберите тип базы `Postgres` и введите указанные значения. Укажите пароль `Htubcnhfnjh`. 
![](./Images/postgresSet.png)

В разделе `Redis` укажите имя сервиса `quayredis`:
![](./Images/redisSet.png)

После ввода минимально необходимых параметров нажмите на появившейся внизу клавише `Validate Configuration Changes`. В случае корректного ввода параметов во всплывающем окне появится надпись `Configuration Validated`: 
![](./Images/validateConfig.png)

Нажмите на клавишу `Download` и загрузите tar-архив конфигурации на локальный компьютер (обычно в `~/Загрузки/quay-config.tar.gz`)

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
