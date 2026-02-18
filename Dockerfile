# ============================================================
# Stage 1: Build
# ============================================================
FROM golang:1.25-alpine AS builder
RUN apk add --no-cache git make
WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN make build

# ============================================================
# Stage 2: Runtime
# ============================================================
FROM alpine:3.23
RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /src/build/picoclaw-linux-amd64 /usr/local/bin/picoclaw
RUN chmod +x /usr/local/bin/picoclaw

# Wrapper to log crash reason and keep container alive for inspection
RUN echo '#!/bin/sh' > /start.sh && \
    echo 'echo "=== Starting picoclaw ==="' >> /start.sh && \
    echo 'echo "Binary check:"' >> /start.sh && \
    echo 'ls -la /usr/local/bin/picoclaw' >> /start.sh && \
    echo 'echo "Running: picoclaw gateway"' >> /start.sh && \
    echo '/usr/local/bin/picoclaw gateway 2>&1' >> /start.sh && \
    echo 'echo "=== EXITED with code $? ==="' >> /start.sh && \
    echo 'sleep 3600' >> /start.sh && \
    chmod +x /start.sh

ENTRYPOINT ["/bin/sh", "/start.sh"]
