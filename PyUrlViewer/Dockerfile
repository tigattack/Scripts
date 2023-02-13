FROM python:3.10-alpine

LABEL org.opencontainers.image.authors="tigattack"
LABEL org.opencontainers.image.title="PyUrlViewer"
LABEL org.opencontainers.image.description="Python HTTP server to serve the contents of the provided URL"
LABEL org.opencontainers.image.url="https://github.com/tigattack/Scripts/tree/main/PyUrlViewer"
LABEL org.opencontainers.image.documentation="https://github.com/tigattack/Scripts/tree/main/PyUrlViewer"
LABEL org.opencontainers.image.source="https://github.com/tigattack/Scripts/tree/main/PyUrlViewer"

EXPOSE 8080

HEALTHCHECK \
  --interval=30s \
  --timeout=10s \
  --start-period=5s \
  --retries=1 \
  CMD ["curl --fail http://localhost:8080/healthcheck || exit 1"]

WORKDIR /app

COPY ./server.py .

ENTRYPOINT [ "python3", "-u", "server.py"]
