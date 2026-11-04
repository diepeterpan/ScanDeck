FROM python:3.12-slim

ARG APP_VERSION=1.0.0

LABEL org.opencontainers.image.title="ScanDeck" \
      org.opencontainers.image.description="Web UI for eSCL network scanners with Paperless-ngx upload and Home Assistant integration." \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.source="https://github.com/diepeterpan/ScanDeck" \
      org.opencontainers.image.licenses="MIT"

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_DATA_DIR=/data \
    SCAN_OUTPUT_DIR=/scans

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY VERSION app.py ./
COPY scandeck ./scandeck
COPY templates ./templates
COPY static ./static
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN useradd --create-home --uid 10001 scanner \
    && mkdir -p /data /scans \
    && chown -R scanner:scanner /app /data /scans \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

# The container starts as root, sets up mounted volumes, and drops to
# the unprivileged "scanner" user in the entrypoint.
# PUID/PGID can be passed to match the host user.
ENV PUID=10001 \
    PGID=10001

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import urllib.request,sys; sys.exit(0 if urllib.request.urlopen('http://127.0.0.1:8080/health', timeout=4).status == 200 else 1)"

# A single worker maintains application state (scan locks, batch, queue) in
# memory. Every open client UI holds an active thread for the event stream,
# hence a generous thread pool: with eight threads, the service stopped responding
# beyond the eighth browser tab.
CMD ["gunicorn", "--workers", "1", "--threads", "32", "--timeout", "0", "--bind", "0.0.0.0:8080", "app:app"]
