# StaticJinjaPlus
StaticJinjaPlus is a tool to build static sites using [Jinja](https://jinja.palletsprojects.com/).

# Content

- [How to install](#How-to-install)
- [Building sites](#Building-sites)
  - [Watching for changes](#Watching-for-changes)
  - [Specifying templates or build paths](#Specifying-templates-or-build-paths)
  - [Using assets](#Using-assets)
  - [Using context](#Using-context)
  - [Шаблоны extends и include](#Шаблоны-extends-и-include)
- [Example templates](#Example-templates)
- [Запуск контейнера](#Docker-start)

## Билд нужной версии
В репозитории хранится несколько `Dockerfile` для разных версий образа:
- `./Dockerfile`: latest-версия / main-ветка репозитория [StaticJinjaPlus](https://github.com/MrDave/StaticJinjaPlus) на базе Ubuntu 22.04
- `./dev/Dockerfile`: dev-версия на базе Ubuntu 22.04, копирует содержимое из папки-репозитория, в которой расположен файл
- `./dev/Dockerfile.slim`: dev-версия на базе образа Python Slim 3.12
- `./0.1.0/Dockerfile`: Версия 0.1.0 StatigJinjaPlus на базе Ubuntu 22.04
- `./0.1.0/Dockerfile.slim`: Версия 0.1.0 StaticJinjaPlus на базе Python Slim 3.12
- `./0.1.1/Dockerfile`: Версия 0.1.1 StatigJinjaPlus на базе Ubuntu 22.04
- `./0.1.1/Dockerfile.slim`: Версия 0.1.1 StaticJinjaPlus на базе Python Slim 3.12

### Примеры команд сборки
#### latest
```bash
sudo docker buildx build \
-t eugenefedyakin/static-jinja:latest .
```

#### dev
```bash
sudo docker buildx build \
-f ./dev/Dockerfile \
-t eugenefedyakin/static-jinja:develop .
```

#### 0.1.0-slim
```bash
sudo docker buildx build \
-f ./0.1.1/Dockerfile.slim \
-t eugenefedyakin/static-jinja:0.1.1-slim .
```

## Запуск нужной версии
### Параметры Docker
- `docker run --rm` удалит контейнер после его выполнения
- `docker run -it` запустит в интерактивном режиме
- `docker run -t --rm` запустит в интерактивном режиме и удалит после завершения работы контейнера

### Аргументы старта контейнера (вконце команды docker run/start)
- `-w`: запустит код в режиме отслеживания для автоматического билда. Контейнер будет работать до тех пор, пока не будет остановлен вручную
- `--srcpath`: путь к папке с шаблонами. По умолчанию: `./templates/`. Должен совпадать с подключаемым `volume` (подробности далее)
- `--srcout`: путь к паке с результатом. По умолчанию: `./build/`. Должен совпадать с подключаемым `volume` (подробности далее)

### Стандартная команда запуска
```bash
sudo docker run --rm \
  -v <path-to-templates>:/opt/app/templates \
  -v <path-to-build>:/opt/app/build \
  <docker-repo>/<image-name>:<image-tag>
```

#### Единоразовый запуск latest с удалением контейнера
```bash
sudo docker run --rm \
  -v ./templates:/opt/app/templates \
  -v ./build:/opt/app/build \
  eugenefedyakin/static-jinja
```

#### Запуск "тонкой" версии 0.1.1 в фоне с отслеживанием изменений
```bash
sudo docker run -d --name jinja-plus-watch \
  -v ./templates:/opt/app/templates \
  -v ./build:/opt/app/build \
  eugenefedyakin/static-jinja:0.1.1-slim \
  -w
```

#### Запуск dev с нестандартными путями в интерактивном режиме
```bash
sudo docker run -it --name jinja-plus \
  -v ./templates:/opt/app/my_templates \
  -v ./build:/usr/src/build \
  eugenefedyakin/static-jinja:develop \
  --srcpath ./my_templates --outpath /usr/src/build
```
Объяснение:
- Локальная папка `./templates` будет смонтирована как `/opt/app/my_templates/` внутри образа. Путь до смонтированной папки должен быть полным.
- `--srcpath` и `--outpath` указывают на папки внутри образа.
- В целом добавление путей не имеет смысла при работе с докер-образом, можно обойтись стандартными путями из привмеров выше

### Удалить контейнеры
#### Удалить запущеный контейнер
```bash
docker rm -f <ids>
```

## Docker Compose
### Запуск в фоне
```bash
docker compose up -d
```
### Просмотр логов
```bash
docker compose logs -f [app-name]
```


## How to install

Python should already be installed. This project requires Python3.7 or newer.

Clone the repo / download code.

Using virtual environment [virtualenv/venv](https://docs.python.org/3/library/venv.html) is recommended for project isolation.

Install requirements:
```commandline
pip install -r requirements.txt
```

To check that everything installed correctly try running the script with `--help` flag:
```commandline
python main.py --help
```
Output:
```
usage: main.py [-h] [-w] [--srcpath SRCPATH] [--outpath OUTPATH]

Render HTML pages from Jinja2 templates

options:
  -h, --help         show this help message and exit
  -w, --watch        Render the site, and re-render on changes to <srcpath>
  --srcpath SRCPATH  The directory to look in for templates (defaults to './templates)'
  --outpath OUTPATH  The directory to place rendered files in (defaults to './build')
```
Now you're all ready to build your static sites!

## How to install with Docker
`docker pull eugenefedyakin/static-jinja:latest`


## Building sites

Note: see [Example templates](#example-templates) section for an example with sample templates. Rename the /templates_example folder to /templates to run test templates.

To render html pages from templates, run:
```commandline
python main.py
```
This will look in `./templates` for templates (files whose name does not start with `.` or `_`) and build them to `./build`.

You'll see a message about each template in the output:
```
Rendering index.html...
```

### Watching for changes
To watch for changes in the templates and recompile build files if changes happen, use `-w` or `--watch` argument.
```commandline
python main.py -w

Rendering index.html...
Watching '/home/mrdave/Python Projects/StaticJinjaPlus/templates' for changes...
Press Ctrl+C to stop.
```

### Specifying templates or build paths

To change the source and/or output paths use optional arguments:  
- `--srcpath` - the directory to look in for templates (defaults to `./templates`)  
- `--outpath` - the directory to place rendered files in (defaults to `.`)

Example:
```commandline
python main.py --srcpath other_template_folder --outpath ./built/site

Rendering index.html...
```

### Using assets

To use assets such as `.css` and `.js` files with your templates, place them in `assets` folder inside source path (so `./templates/assets` by default).
In this case StaticJinjaPlus will copy the assets to output folder keeping the same relative paths.

Building log will also include "rendering" the assets:

```commandline
python main.py

Rendering assets/style.css...
Rendering index.html...
```

### Using context
It is possible to pass context for use in your templates by setting environmental variables named as you use them in the templates with the `"SJP_"` prefix.

As an example, if your template includes `thing` variable, pass the `SJP_THING` env variable before building.

```html
<!-- html template -->
<div class="container">
    <h1>Welcome to our website!</h1>
    <p>This is the homepage content. Replace it with your own.</p>
    <p>The thing from context is {{ thing }}</p>
</div>
```
```shell
export SJP_THING="my_thing"
python main.py
```
![](https://imgur.com/TEf3yJ6.png)


## Шаблоны extends и include

- Вызов `extends` используется когда шаблоны должны иметь одинаковую базовую структуру, одну и ту же разбивку по блокам, но с разным содержимым для этих блоков. Это позволяет сформировать единообразный стиль сайта, когда веб-страницы имеют одни и те же структурные элементы - меню, хедер, футер, сайдбары и так далее.

Пример кода:

```html
<!-- index.html file -->

{% extends '_base.html' %}
```

- Вызов `include` добавляет в нужное место кусок шаблона. Название подключаемого шаблона передается в качестве параметра.
  
Пример вызова `include` для файла `_card.html` из `index.html`. Имя файла `_card.html` имеет префикс «`_`» что объявляет его вспомогательным (подключаемым). При изменении вспомогательного файла рендерятся все файлы в которых есть к нему обращения. В данной конструкции передадим еще две переменные `page` и  `number`.

```html
<!-- index.html file -->

{% with page="Домашняя", number=1 %}
  {% include "_card.html" %}
{% endwith %}
```

Пример кода с переменными `page` и `number`.
  
```html
<!-- _card.html file -->

<p>Вывод текста из файла _card.html методом include. Страница {{page}} Номер {{number}} </p>
```

<img width="738" alt="image" src="https://github.com/SGKespace/StaticJinjaPlus/assets/55636018/6fbce118-e5ae-46b8-b5e5-7ab4df323562">


## Example templates
The repository has example templates to see how StaticJinjaPlus works.

Run the following command and see your results in `./build`:
```commandline
python main.py --srcpath example/templates
```
```shell
build
├── about.html
├── assets
│  └── style.css
├── faq.html
└── index.html

```
![Example of index.html](https://imgur.com/Onr3aVM.jpg)
Example render of `index.html`
