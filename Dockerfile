# syntax=docker/dockerfile:1
FROM python:3.12.12
RUN <<EOT bash
  set -ex
  apt-get update
  apt-get install python3.12
  rm -rf /var/lib/apt/lists/*
EOT
RUN <<EOT bash
  apt-get install pip3
  rm -rf /var/lib/apt/lists/*
EOT