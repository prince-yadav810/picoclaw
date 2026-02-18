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

ENTRYPOINT ["picoclaw"]
CMD ["gateway"]
