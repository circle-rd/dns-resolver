# AI Stack — CoreDNS with envsubst configuration support
#
# CoreDNS's official image is scratch-based (no shell).
# We copy the binary into Alpine so we can run a config-generation entrypoint.
# docker-gen watches the Docker socket and rewrites the hosts file on container
# events; we copy it from the official multi-arch image (0.16+ required for the
# Networks-as-slice template syntax used in templates/hosts.tmpl).

FROM coredns/coredns:1.12.0 AS coredns-bin
FROM nginxproxy/docker-gen:latest AS docker-gen-bin

FROM alpine:3.21

RUN apk add --no-cache gettext

# Copy binaries from their respective upstream images
COPY --from=coredns-bin /coredns /usr/local/bin/coredns
COPY --from=docker-gen-bin /usr/local/bin/docker-gen /usr/local/bin/docker-gen

# Bundle templates and entrypoint — all generated at container startup
COPY entrypoint.sh Corefile.template zone.template templates/hosts.tmpl /templates/
RUN chmod +x /templates/entrypoint.sh \
    && mkdir -p /etc/coredns/zones

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/templates/entrypoint.sh"]
