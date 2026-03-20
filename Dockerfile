# AI Stack — CoreDNS with envsubst configuration support
#
# CoreDNS's official image is scratch-based (no shell).
# We copy the binary into Alpine so we can run a config-generation entrypoint.

FROM coredns/coredns:1.12.0 AS coredns-bin

FROM alpine:3.21

RUN apk add --no-cache gettext

# Copy the CoreDNS binary from the official (scratch-based) image
COPY --from=coredns-bin /coredns /usr/local/bin/coredns

# Bundle templates and entrypoint — all generated at container startup
COPY entrypoint.sh Corefile.template zone.template /templates/
RUN chmod +x /templates/entrypoint.sh \
    && mkdir -p /etc/coredns/zones

EXPOSE 53/udp 53/tcp

ENTRYPOINT ["/templates/entrypoint.sh"]
