#!/bin/sh
# dns-resolver — unified entrypoint
# Generates Corefile and zone file from templates using envsubst,
# then starts CoreDNS and docker-gen as co-managed processes.
set -e

: "${DOMAIN:?DOMAIN environment variable is required}"
: "${HOST_IP:?HOST_IP environment variable is required}"
DNS_UPSTREAM="${DNS_UPSTREAM:-1.1.1.1}"
DNS_AUTHORITATIVE="${DNS_AUTHORITATIVE:-true}"
ACME_DNS_ENABLED="${ACME_DNS_ENABLED:-false}"
# Reload intervals — how often CoreDNS re-reads files changed by docker-gen.
HOSTS_RELOAD="${HOSTS_RELOAD:-15s}"
ZONE_RELOAD="${ZONE_RELOAD:-30s}"
# docker-gen debounce — wait at least MIN before rewriting, at most MAX.
DOCKERGEN_WAIT="${DOCKERGEN_WAIT:-5s:30s}"
export DNS_UPSTREAM HOSTS_RELOAD ZONE_RELOAD DOCKERGEN_WAIT

echo "=== DNS Resolver (CoreDNS + docker-gen) ==="
echo "  Domain       : ${DOMAIN}"
echo "  Host IP      : ${HOST_IP}"
echo "  Upstream DNS : ${DNS_UPSTREAM}"
echo "  Authoritative: ${DNS_AUTHORITATIVE}"
echo "  ACME DNS-01  : ${ACME_DNS_ENABLED}"
echo "  Hosts reload : ${HOSTS_RELOAD}  (CoreDNS re-reads /etc/coredns/hosts)"
echo "  Zone reload  : ${ZONE_RELOAD}  (CoreDNS re-reads the zone file)"
echo "  docker-gen   : wait ${DOCKERGEN_WAIT}  (min:max debounce)"

# ── Zone serial — date-based (YYYYMMDDNN) ──────────────────────────────────
SERIAL="$(date -u +'%Y%m%d%H')"
export SERIAL

# ── Domain-zone forward directive ──────────────────────────────────────────
# DNS_AUTHORITATIVE=true  (default) → no forward directive in the domain block
#   → unknown domain names return NXDOMAIN (fully authoritative behaviour)
# DNS_AUTHORITATIVE=false → add forward to upstream inside the domain block
#   → split-horizon: known names return HOST_IP, unknown names are forwarded
if [ "${DNS_AUTHORITATIVE}" = "false" ]; then
    DNS_DOMAIN_FORWARD="forward . ${DNS_UPSTREAM}"
else
    DNS_DOMAIN_FORWARD=""
fi
export DNS_DOMAIN_FORWARD

# ── ACME DNS-01 forward block ───────────────────────────────────────────────
# ACME_DNS_ENABLED=true → ajoute un stanza forward dans le Corefile qui proxy
# toutes les requêtes auth.${DOMAIN} vers le sidecar acme-dns (REST + DNS).
if [ "${ACME_DNS_ENABLED}" = "true" ]; then
    ACME_DNS_BLOCK="# ── ACME DNS-01 challenge zone ──────────────────────────────────────────────────
# Proxy all auth.${DOMAIN} queries to the acme-dns sidecar.
auth.${DOMAIN}:53 {
    forward . acme-dns:53
    errors
    log
}"
else
    ACME_DNS_BLOCK=""
fi
export ACME_DNS_BLOCK

# ── Generate zone file ─────────────────────────────────────────────────────
# Note: envsubst is called with an explicit variable list so that DNS zone
# directives starting with $ (e.g. $TTL, $ORIGIN) are NOT substituted.
mkdir -p /etc/coredns/zones
envsubst '${DOMAIN} ${HOST_IP} ${SERIAL}' \
    < /templates/zone.template \
    > "/etc/coredns/zones/db.${DOMAIN}"

# ── Generate Corefile ──────────────────────────────────────────────────────
envsubst '${DOMAIN} ${DNS_UPSTREAM} ${DNS_DOMAIN_FORWARD} ${ACME_DNS_BLOCK} ${HOSTS_RELOAD} ${ZONE_RELOAD}' \
    < /templates/Corefile.template \
    > /etc/coredns/Corefile

# Seed an empty hosts file (populated at runtime by docker-gen)
touch /etc/coredns/hosts

echo "=== Generated Corefile ==="
cat /etc/coredns/Corefile
echo "=========================="

# Start docker-gen in the background — watches Docker socket and rewrites the
# hosts file on every container start/stop (5 s debounce, 30 s max delay).
docker-gen -watch -wait "${DOCKERGEN_WAIT}" /templates/hosts.tmpl /etc/coredns/hosts &
DOCKER_GEN_PID=$!
echo "docker-gen started (PID ${DOCKER_GEN_PID})"

# Start CoreDNS in the background so we can capture its PID.
coredns -conf /etc/coredns/Corefile &
COREDNS_PID=$!
echo "coredns started (PID ${COREDNS_PID})"

# Forward SIGTERM / SIGINT to both child processes for a clean shutdown.
trap 'kill ${DOCKER_GEN_PID} ${COREDNS_PID} 2>/dev/null' TERM INT

# Keep the entrypoint alive until one of the processes exits.
wait ${COREDNS_PID} ${DOCKER_GEN_PID}
