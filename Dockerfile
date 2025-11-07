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
RUN <<EOT bash
  git clone https://github.com/MrDave/StaticJinjaPlus.git .
EOT
RUN <<EOT bash
  pip install -r requirements.txt
EOT
