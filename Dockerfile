FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

ARG BASE_DIR=/opt/app/
WORKDIR ${BASE_DIR}

ENV \
    # python
    PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1

RUN apt update \
    && apt install git -y \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip

# Использовать для dev-версий
# Переустановит зависимости, только если изменился requirements.txt
COPY requirements.txt ./requirements.txt
RUN pip install -r requirements.txt
COPY . .

# Использовать для prod-версий
# RUN git clone -b 0.1.1 --single-branch https://github.com/MrDave/StaticJinjaPlus.git .
# RUN pip install -r requirements.txt

ENTRYPOINT ["python", "main.py"]
# CMD ["-w", "--srcpath", "./templates", "--outpath", "./build"]  # Пути заданы в коде по умолчанию. -w передавать принудительно