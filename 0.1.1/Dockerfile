FROM ubuntu:22.04

ARG BASE_DIR=/opt/app/
WORKDIR ${BASE_DIR}

ARG \
    REPO_TAG=0.1.1 \
    CHECKSUM=30d9424df1eddb73912b0e2ad5375fa2c876c8e30906bec91952dfb75dcf220b \
    REPO="https://github.com/MrDave/StaticJinjaPlus" \
    TEMP="/tmp/app.tar.gz"

ENV \
    # python
    PYTHONUNBUFFERED=1 \
    # prevents python creating .pyc files
    PYTHONDONTWRITEBYTECODE=1 \
    VERSION=$REPO_TAG

RUN apt update && apt install -y \
    python3 \
    python3-pip \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip

# Использовать для prod-версий
ADD --checksum=sha256:${CHECKSUM} ${REPO}/archive/refs/tags/${VERSION}.tar.gz ${TEMP}
RUN tar xzf ${TEMP} --strip-components=1 -C ${BASE_DIR} && rm ${TEMP}
RUN pip install -r requirements.txt

ENTRYPOINT ["python3", "main.py"]
# CMD ["-w", "--srcpath", "./templates", "--outpath", "./build"]  # Пути заданы в коде по умолчанию. -w передавать принудительно