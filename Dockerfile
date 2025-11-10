FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ARG BASE_DIR=/opt/app/
WORKDIR ${BASE_DIR}

ENV \
    # python
    PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1

RUN <<EOT bash
  set -ex
  apt update
  apt install git -y && rm -rf /var/lib/apt/lists/*
EOT

RUN python -m pip install --upgrade pip

# Переустановим зависимости, только если изменился requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install -r requirements.txt

COPY . .
# RUN git clone https://github.com/MrDave/StaticJinjaPlus.git . 

ENTRYPOINT ["python", "main.py"]
# CMD ["-w", "--srcpath", "./templates", "--outpath", "./build"]  # Пути заданы в коде по умолчанию. -w передавать принудительно