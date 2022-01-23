## Описание списка образов

На настоящий момент (24.01.2022) поддерживаются postgres-образы дистрибутива `ALTLinux` для платформ `p10` и `sisyphus`
версий `10`, `11`, `12`, `13`, `14`.
Имя регистратора хранится в файле `.env` в переменной `REGISTER`. 
На настоящий момент он содержит имя регистратора  `quay.io`:
```
REGISTRY=quay.io
```
Имена поддерживаемых образов:
```
quay.io/altlinux/postgres10:p10
quay.io/altlinux/postgres10:sisyphus
quay.io/altlinux/postgres11:p10
quay.io/altlinux/postgres11:sisyphus
quay.io/altlinux/postgres12:p10
quay.io/altlinux/postgres12:sisyphus
quay.io/altlinux/postgres13:p10
quay.io/altlinux/postgres13:sisyphus
quay.io/altlinux/postgres14:p10
quay.io/altlinux/postgres14:sisyphus
```

### Сборка образов 

Сборка образов производится скриптом `build.sh`.
Список генерируемых платформ задается переменной `PLATFORMS`.
Если переменная не задана образы генерируются для платформ `p10`, `sisyphus`.
Скрипту параметрами передается список генерируемых версий. 
Если параметры отсутствуют, образы генерируются для всех версий.

### Размещение образов в регистраторе

Размещение образов в регистраторе производится скриптом `push.sh`.
Список размещаемых платформ задается переменной `PLATFORMS`.
Если переменная не задана размещаются образы  для платформ `p10`, `sisyphus`.
Скрипту параметрами передается список генерируемых версий. 
Если параметры отсутствуют, размещаются образы для всех версий.


## Описание образов postgres

В образах используется модифицировнный стартовый скрипт официального образа
[docker-entrypoint.sh](https://github.com/docker-library/postgres/blob/master/docker-entrypoint.sh).

Таким образом для настойки и работы с образами можно использовать документацию
[официального postgres-образа docker](https://hub.docker.com/_/postgres)

## Ссылки

1. [Описание официального образа docker](https://hub.docker.com/_/postgres)
