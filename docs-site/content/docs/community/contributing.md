---
title: Contributing
description: How to contribute to DNS Resolver.
---

# Contributing

Contributions are welcome. Please open issues and pull requests on the [DNS Resolver GitHub repository](https://github.com/circle-rd/dns-resolver).

## What to contribute

- Bug reports — include the output of `docker compose logs dns` and your environment variables (redact `HOST_IP` if needed)
- Feature requests — open an issue describing the use case and the environment variable(s) you would expect
- Template improvements — `templates/hosts.tmpl`, `Corefile.template`, `zone.template`
- `entrypoint.sh` fixes — POSIX sh only; must run in BusyBox `sh` (Alpine)

## Development setup

```bash
git clone https://github.com/circle-rd/dns-resolver.git
cd dns-resolver

# Build the image locally
docker build -t dns-resolver:dev .

# Run with test environment variables — prints the generated Corefile and exits
docker run --rm \
  -e DOMAIN=test.local \
  -e HOST_IP=127.0.0.1 \
  dns-resolver:dev sh -c '
    DOMAIN=test.local HOST_IP=127.0.0.1 /templates/entrypoint.sh &
    sleep 2
    cat /etc/coredns/Corefile
    kill %1
  '
```

## Testing DNS resolution locally

```bash
# Start with a test config
docker run --rm \
  -e DOMAIN=test.local \
  -e HOST_IP=127.0.0.1 \
  -p 5353:53/udp \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  dns-resolver:dev

# In another terminal
dig @127.0.0.1 -p 5353 anything.test.local A +short
# → 127.0.0.1
```

## Code style

- Entrypoint: **POSIX sh** (`#!/bin/sh`) — no bashisms
- Templates: CoreDNS config syntax + Go `text/template` (hosts.tmpl)
- No new environment variables without updating `README.md`, `.env.example`, and the documentation

## Reporting security issues

Please use the GitHub repository security advisories feature — do not open public issues for security vulnerabilities.
