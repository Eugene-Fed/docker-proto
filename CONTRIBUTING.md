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

#### Билд образа
```bash
sudo docker buildx build -t <repository:tag> .  # заменить точку вкоцне на путь, если запускается не из корня
```

#### Запуск контейнера
```bash
sudo docker run --name <container_name> -it <repository:tag> /bin/bash
```


#### Запуск нового контейнера
```bash
sudo docker run -it  ubuntu:22.04 # Скачивает образ при необходимости и запускает контейнер в интерактивном режиме
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