# ─── Stage 1: Builder ──────────────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY pyproject.toml README.md ./
COPY src/ ./src/

RUN pip install --upgrade pip --quiet && \
    pip install --no-cache-dir --prefix=/deps -e . 2>/dev/null || \
    pip install --no-cache-dir --prefix=/deps -r requirements.txt 2>/dev/null || \
    echo "No installable dependencies"

# ─── Stage 2: Runtime ──────────────────────────────────────────────────────
FROM python:3.11-slim AS runtime

LABEL org.opencontainers.image.title="Sovereign Field LMS"
LABEL org.opencontainers.image.description="Offline-first Learning Management System for field technicians. Delivers structu"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.vendor="BlackFox Gaming Studio"
LABEL org.opencontainers.image.source="https://github.com/BlackFoxgamingstudio/field-lms"
LABEL org.opencontainers.image.licenses="MIT"

# Security: non-root user
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --shell /bin/bash --no-create-home appuser

WORKDIR /app

COPY --from=builder /deps /usr/local
COPY --chown=appuser:appgroup . .

USER appuser

EXPOSE 8789

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD python3 -c "\
import urllib.request, sys; \
try: urllib.request.urlopen('http://localhost:8789/health', timeout=5); sys.exit(0) \
except: sys.exit(1)"

ENTRYPOINT ["python3", "src/core.py"]
