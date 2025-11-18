# Latest
# Стоит ли использовать и latest-ubuntu?
FROM ubuntu:22.04

ARG BASE_DIR=/opt/app/
WORKDIR ${BASE_DIR}

ARG \
    REPO="https://github.com/MrDave/StaticJinjaPlus" \
    TEMP="/tmp/app.tar.gz"

ENV \
    # python
    PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1

RUN apt update && apt install -y \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip

# Использовать для lates-версии
RUN apt-get update && apt-get install -y git \
    && git clone ${REPO}.git . \
    && apt-get remove -y git \
    && apt-get autoremove -y \
    && rm -rf /app/.git \
    && rm -rf /var/lib/apt/lists/*

RUN pip install -r requirements.txt

ENTRYPOINT ["python3", "main.py"]
# CMD ["-w", "--srcpath", "./templates", "--outpath", "./build"]  # Пути заданы в коде по умолчанию. -w передавать принудительно