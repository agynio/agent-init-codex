# syntax=docker/dockerfile:1
FROM alpine:3.21

ARG AGYND_VERSION
ARG AGYN_VERSION
ARG CODEX_VERSION
ARG TARGETARCH

RUN mkdir -p /tools/cli

RUN apk add --no-cache curl && \
    curl -fsSL "https://github.com/agynio/agynd-cli/releases/download/v${AGYND_VERSION}/agynd-linux-${TARGETARCH}" \
      -o /tools/agynd && \
    chmod +x /tools/agynd && \
    curl -fsSL "https://github.com/agynio/agyn-cli/releases/download/v${AGYN_VERSION}/agyn-linux-${TARGETARCH}" \
      -o /tools/cli/agyn && \
    chmod +x /tools/cli/agyn

RUN case "${TARGETARCH}" in \
      amd64) ARCH="x86_64" ;; \
      arm64) ARCH="aarch64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    curl -fsSL "https://github.com/openai/codex/releases/download/rust-v${CODEX_VERSION}/codex-${ARCH}-unknown-linux-musl.tar.gz" \
      | tar -xz -C /tools/ && \
    mv "/tools/codex-${ARCH}-unknown-linux-musl" /tools/codex && \
    chmod +x /tools/codex

COPY config.json /tools/config.json

ENTRYPOINT ["cp", "-a", "/tools/.", "/agyn-bin/"]
