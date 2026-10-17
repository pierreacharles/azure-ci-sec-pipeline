FROM python:3.11-slim-trixie AS build

WORKDIR /app
COPY src/ado_package/main.py ./main.py
RUN python -m compileall -q main.py

FROM python:3.11-slim-trixie AS runtime

ARG BUILD_VERSION=dev
LABEL org.opencontainers.image.title="AGA ADO Package" \
      org.opencontainers.image.version="${BUILD_VERSION}"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN python -m pip install --no-cache-dir --upgrade setuptools \
    && groupadd --system --gid 10001 app \
    && useradd --system --uid 10001 --gid app --home-dir /app app
WORKDIR /app
COPY --from=build --chown=10001:10001 /app/main.py ./main.py

USER 10001:10001
ENTRYPOINT ["python", "-u", "main.py"]
