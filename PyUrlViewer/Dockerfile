FROM python:3.10-alpine

EXPOSE 8080

HEALTHCHECK \
  --interval=30s \
  --timeout=10s \
  --start-period=5s \
  --retries=1 \
  CMD ["curl --fail http://localhost:8080/healthcheck || exit 1"]

WORKDIR /app

COPY . .

ENTRYPOINT [ "python3", "-u", "server.py"]
