# ============================================================
# Stage 1: Build the picoclaw binary
# ============================================================
FROM golang:1.25-alpine AS builder
RUN apk add --no-cache git make
WORKDIR /src
# Cache dependencies
COPY go.mod go.sum ./
RUN go mod download
# Copy source and build
COPY . .
RUN make build

# ============================================================
# Stage 2: Minimal runtime image
# ============================================================
FROM alpine:3.23
RUN apk add --no-cache ca-certificates tzdata curl

# Copy binary (use actual filename, not symlink)
COPY --from=builder /src/build/picoclaw-linux-amd64 /usr/local/bin/picoclaw
RUN chmod +x /usr/local/bin/picoclaw

# Create non-root user and group
RUN addgroup -g 1000 picoclaw && \
    adduser -D -u 1000 -G picoclaw picoclaw

# Switch to non-root user
USER picoclaw

# Run onboard to create initial directories and config
RUN /usr/local/bin/picoclaw onboard

ENTRYPOINT ["picoclaw"]
CMD ["gateway"]
