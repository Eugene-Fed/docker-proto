# Разработчикам StaticJinjaPlus

В этом документе собраны те рекомендации и инструкции, которые необходимы разработчикам StaticJinjaPlus, но бесполезны для прикладных программистов — пользователей StaticJinjaPlus. Если вы пользователь, а не разработчик StaticJinjaPlus — перейдите в [README.md](https://github.com/MrDave/StaticJinjaPlus/blob/main/README.md).

## Оглавление

- [Как развернуть local-окружение](#Как-развернуть-local-окружение)
   - [Хуки pre-commit](#Хуки-pre-commit)
   - [Как запустить линтеры Python](#Как-запустить-линтеры-Python)
   - [Pytest](#Pytest)



## Как развернуть local-окружение

Для разработки ПО и запуска автотестов вам понадобится набор инструментов. Инструкции по их установке ищите на официальных сайтах:

- [Install Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Install pre-commit hooks manager](https://pre-commit.com/)

Склонируйте репозиторий. Перейдите в корневой каталог репозитирия.

Создайте виртуальное окружение:

```PowerShell
StaticJinjaPlus$ python3 -m venv ../venv
```

Активируйте виртуальное окружение. На разных операционных системах это делается разными командами:

- Windows: `.\venv\Scripts\activate`
- MacOS/Linux: `source ../venv/bin/activate`

Установите все зависимости, включая библиотеки для разработки и отладки:

```PowerShell
StaticJinjaPlus$ pip install -r requirements-dev.txt
```


## Хуки pre-commit

В репозитории используются хуки pre-commit, чтобы автоматически запускать линтеры и автотесты. 
В корне репозитория запустите команду для настройки хуков:

```PowerShell
StaticJinjaPlus$ pre-commit install
```

В последующем при коммите автоматически будут запускаться линтеры и автотесты. Есть линтеры будет недовольны, или автотесты сломаются, то коммит прервётся с ошибкой.

<img width="725" alt="image" src="https://github.com/SGKespace/StaticJinjaPlus/assets/55636018/9ce1b85c-fd69-45dd-9846-77c0fc2b3d22">


## Как запустить линтеры Python

Перед запуском линтеров предварительно активируйте виртуальное окружение:

Запустите линтер Flake8:

```PowerShell
StaticJinjaPlus$ flake8
```

Пример результата вывода

<img width="632" alt="image" src="https://github.com/SGKespace/StaticJinjaPlus/assets/55636018/d652d97e-5265-4735-8730-5b9c83f1c24d">

Запуск линтер mypy:

```PowerShell
StaticJinjaPlus$ mypy main.py
Success: no issues found in 1 source file
```


## Pytest

Pytest используется для написания и запуска автотестов.

Запустите автотесты предварительно активировав виртуальное окружение:

```shell
$ pytest
=========================== test session starts ===========================
platform win32 -- Python 3.11.5, pytest-8.1.1, pluggy-1.4.0
collected 2 items
rootdir: C:\Dev\StaticJinjaPlus
test_sample.py .F                         [100%]
================================= FAILURES ========================================
___________________________________ test_wrong_answer ____________________________
    def test_wrong_answer():
>       assert func(10) == 5
E       assert 11 == 5
E        +  where 11 = func(10)

test_sample.py:9: AssertionError

FAILED test_sample.py::test_wrong_answer - assert 11 == 5
=========================== 1 failed, 1 passed in 0.10s ===========================
```

## Docker

### Dockerfile
Добавлять команду очистки `apt` внутри каждого слоя установки
```bash
rm -rf /var/lib/apt/lists/*
```
Пример:
```
RUN apt update \
    && install git -y \
    && rm -rf /var/lib/apt/lists/*

```
**Важно**: Вполнять очистку кеша (последняя команда) одной командой с **кажой** утановкой пакетов.

### Билд образа
Не забыть обновить .dockerignore перед билдом. Например командой
```bash
sudo cp .gitignore .dockerignore
```

```bash
sudo docker buildx build -t <docker-repo>:<tag> .  # заменить точку вкоцне на путь, если запускается не из корня
sudo docker buildx build -t <docker-repo>:latest .  # Обновить Образ для latest
```
Пример для добавления тега версии и latest одной командой:
```bash
sudo docker buildx build -t eugenefedyakin/static-jinja:11.10.4-test -t eugenefedyakin/static-jinja:latest .
```

#### Аргументы билда
```
ARG <name>[=<default value>] [<name>[=<default value>]...]
```

#### Запуск с аргументами
```bash
docker build --build-arg argname[=argvalue] .  # Если задано значение по умоланию, оно опционально при запуске
```

[Документация](https://docs.docker.com/reference/dockerfile/#arg)

#### Запуск конкретного Dockefile
```bash
sudo docker buildx build -f Dockerfile.dev -t myapp:dev .
```

### Удалить образ
```bash
docker rmi <имя-образа>  # Удалит образ, если от него нет контейнеров
docker rmi -f <имя-образа>  # Принудительно остановит и удалить контейнер вместе с образом
```


### Запуск контейнера
```bash
sudo docker run --name <container_name> -d <docker-repo>:<tag> [-w, [--srcpath, path-to-dir, [--outpath, path-to-dir]]]
```
- `-d` для фоновой работы контейнера
- `-it` (вместо `-d`)для запуска терминала контейнера в интерактивном режиме
- `-w` запуск контейнера в режиме "отслеживания изменений". Автоматически обновляет билд. По умолчанию запускается, отрабатывает и завершает работу
- `--srcpath path-to-dir` указать, если шаблоны лежат не в ./templates приложения
- `--outpath path-to-dir` указать, если результат класть не в ./build приложения

Пример
```bash
docker run -d --rm --name static-jinja eugenefedyakin/static-jinja
```
Запустит контейнер, выполнит задачу, завершит и удалит контейнер

#### Запуск контейнера с проверкой изменений
В отличие от `docker run`, который скачает образ только если его тег ещё отсутствует локально, `docker pull` также проверит разницу в локальной и origin-версия. Особенно актуально для `:latest`. Например:
```bash
docker run nginx  # После первого запуска будет всегда запускать одну версию, даже при обновлении
docker pull nginx  # При каждом запуске будет сравнивать локальный и origin latest
```

#### Добавление секретов
[Документация](https://docs.docker.com/reference/dockerfile/#run---mounttypesecret)
```bash
docker run --mount=type=secret ..
```

#### Перезапуск существующего контейнера
```bash
sudo docker start -ai <имя_или_ID_контейнера>
```

#### Bash активного контейнера
```bash
docker exec -it <имя_или_ID_контейнера> /bin/bash
# Создаёт новую интерактивную сессию внутри контейнера.
# Выход: exit или Ctrl+D
```
или
```bash
docker attach <имя_или_ID_контейнера>
# Подключается к основному процессу контейнера
# TODO Проверить и скорректировать команду
```

#### Варианты запуска ОБРАЗА
```bash
docker run --detach # run container in background
docker run --attach # attach to stdin, stdout, and stderr
docker run --tty # allocate a pseudo-tty
docker run --interactive # keep stdin open even if not attached
```

#### Перезапуск остановленного КОНТЕЙНЕРА
```bash
docker start <опции> <имя_или_ID_контейнера>
# -ai для запуска в интерактивном режиме
# -d для запуска в фоне
```

#### Остановить контейнер
```bash
docker stop  <имя-или-id-контейнера>
```

#### Удалить остановленный контейнер
```bash
docker rm <имя-или-id-контейнера>
```

### Docker Volumes
[Примеры основных команд](https://docs.docker.com/reference/cli/docker/volume/)


#### Удаление всех Volumes
```bash
docker volume prune
```

#### Создание контейнера с Volume
```bash
docker run --mount type=volume,src=<volume-name>,dst=<mount-path>  # Универсальный способ с большим набором опций
docker run --volume <volume-name>:<mount-path>  # Более короткий вариант команды
docker run -v [<volume-name>:]<mount-path>[:opts]
```
- [Документация](https://docs.docker.com/engine/storage/volumes/#options-for---mount)
- `mount-path` -- это путь, куда будет смонтирован Volume ВНУТРИ контейнера
- Для -v / --volume доступны только 2 опции:
   - `readonly` / 'ro' -- контент Volume будет доступен внутри конейтена только для чтения
   - `volume-nocopy` -- если под
ключенный Volume пуст, то в него не будет скопировано содержимое `mount-pash` папки из контейнера. Если опция не указана, то пустой волюм будет заполнен данными из папки контейнера.
   Пример `docker run -v myvolume:/data:ro`

#### Прямое монтирование папки хоста (не Volume)
```bash
docker run -v <host-folder-path>:<container-folder-path>
# Например
docker run -v /home/user/myapp:/app
```
Полный пример:
```bash
sudo docker run --rm -v ./templates/:/opt/app/templates/ -v ./build/:/opt/app/build/ eugenefedyakin/static-jinja
```
- Запустит контейнер для `latest` образа `eugenefedyakin/static-jinja`
- Смонтирует папки `templates/` и `build/` текущей директории внутрь контейнера (**важно:** указывать полный путь)
- Удалит контейнер после выполнения (`-rm`)


#### Путь до контента Volume
Volume хранятся в директории с root доступом  
`/var/lib/docker/volumes/<volume-name>/_data`

Найти можно командой в разделе "Mountpoint"
```bash
docker volume inspect <volume-name>
```

#### Создать именованный Volume 
```bash
docker volume create my-vol
```

#### Список Volumes
```bash
docker volume ls
```
  
Получить инфо по Volume
```bash
docker volume inspect my-vol  # Вернёт в консоль JSON
```

#### Compose with Volume
[Ссылка](https://docs.docker.com/engine/storage/volumes/#use-a-volume-with-docker-compose)

### Docker Service
[Ссылка][https://docs.docker.com/engine/storage/volumes/#start-a-service-with-volumes]

## Файловая система Linux
[Ссылка](https://refspecs.linuxfoundation.org/fhs.shtml)

## Docker push
Задать теги для новой версии образа:
```bash
docker image tag <image-name> <docker-repo>/<image-name>:<tag>  # Задаст тег для последней версии
docker image tag <image-name> <docker-repo>/<image-name>:latest  # Обновит образ для latest
```

[Ссылка](https://docs.docker.com/reference/cli/docker/image/push/)
```bash
docker image push -a <docker-repo>/<image-name>  # -a / --all-tags: все тэги образа
docker image push <docker-repo>/<image-name>:<tag> # Пуш конкретного тега
```
  
Примеры
```bash
docker image push --all-tags registry-host:5000/myname/myimage
docker image push -a eugenefedyakin/static-jinja
docker image push eugenefedyakin/static-jinja:11.10
```

## Dockerfile
### Задать рабочую папку внутри образа
```
ARG BASE_DIR=/opt/app/
WORKDIR ${BASE_DIR}
```

### Клонировать конкретный тег репозитория
```
RUN git clone -b v1.2.3 --single-branch https://github.com/user/repo.git /app/repo
```
- `-b` задаёт ветку или конкретный тег aka именованный коммит репозитория
- `--singe-branch` задаёт скачивание только указанной ветки
- `/app/repo` целевая папка внутри Docker образа. `.` задаёт текщую папку

### Получить Контрольную сумму архива репозитория
```bash
curl -sL https://github.com/MrDave/StaticJinjaPlus/archive/refs/tags/0.1.0.tar.gz | sha256sum
```

### Получить версию кода GitHub с проеркой контрольной суммы
```
ADD --checksum=sha256:<check-sum> <url-to-archive> <tmp-path-in-image.tar.gz>

RUN tar xzf <tmp-path-in-image.tar.gz> --strip-components=1 -C <target-app-path> && rm <tmp-path-in-image.tar.gz>
```

Пример
```
ADD --checksum=sha256:3555bcfd670e134e8360ad934cb5bad1bbe2a7dad24ba7cafa0a3bb8b23c6444 https://github.com/MrDave/StaticJinjaPlus/archive/refs/tags/0.1.0.tar.gz /tmp/app.tar.gz

RUN tar xzf /tmp/app.tar.gz --strip-components=1 -C /app && rm /tmp/app.tar.gz
```