# syntax=docker/dockerfile:1.7
ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.1.1
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_ARCH
ARG TELEMT_VERSION=3.5.2

# hadolint ignore=DL3018
RUN apk add --no-cache --no-progress \
        ca-certificates \
        curl \
        darkhttpd \
    && case "${BUILD_ARCH}" in \
        amd64) asset="telemt-x86_64-linux-musl.tar.gz" ;; \
        aarch64) asset="telemt-aarch64-linux-musl.tar.gz" ;; \
        *) echo "Unsupported arch: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac \
    && base="https://github.com/telemt/telemt/releases/download/${TELEMT_VERSION}" \
    && curl -fsSL --retry 5 -o "/tmp/${asset}" "${base}/${asset}" \
    && curl -fsSL --retry 5 -o "/tmp/${asset}.sha256" "${base}/${asset}.sha256" \
    && (cd /tmp && sha256sum -c "${asset}.sha256") \
    && tar -xzf "/tmp/${asset}" -C /tmp \
    && install -m 0755 "$(find /tmp -type f -name telemt | head -n1)" /usr/bin/telemt \
    && rm -rf /tmp/* \
    && mkdir -p /etc/telemt /opt/ha-telemt/web

COPY rootfs /

EXPOSE 18080

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD pidof telemt >/dev/null || exit 1

ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version="${BUILD_VERSION}" \
    maintainer="ad <unsecuredregister@gmail.com>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.source="${BUILD_REPOSITORY}" \
    org.opencontainers.image.revision="${BUILD_REF}" \
    org.opencontainers.image.created="${BUILD_DATE}" \
    org.opencontainers.image.version="${BUILD_VERSION}"
