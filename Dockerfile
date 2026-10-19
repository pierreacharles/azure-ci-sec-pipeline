# AUTHOR NAME: Pierre-Antoine Charles
# DATE: Friday 2-Oct-2026
# SUBJECT: GitHub trigger for Azure CI security pipeline containing Docker and Kubernetes CD development.
# ==========================================================================================

# =====================
# DOCKERFILE-BUILD
# =====================

FROM python:3.11-alpine AS build

WORKDIR /app
COPY src/ado_package/main.py ./main.py
RUN python -m compileall -q main.py

FROM python:3.11-alpine AS runtime

ARG BUILD_VERSION=dev
LABEL org.opencontainers.image.title="AGA ADO Package" \
      org.opencontainers.image.version="${BUILD_VERSION}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN apk upgrade --no-cache \
    && python -m pip install --no-cache-dir --upgrade setuptools \
    && addgroup -S -g 10001 app \
    && adduser -S -D -H -u 10001 -G app app
WORKDIR /app
COPY --from=build --chown=10001:10001 /app/main.py ./main.py

USER 10001:10001
ENTRYPOINT ["python", "-u", "main.py"]
