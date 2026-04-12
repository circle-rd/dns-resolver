---
seo:
  title: DNS Resolver — Internal DNS with automatic container discovery
  description: Internal DNS resolver combining CoreDNS and docker-gen — automatic container discovery for private networks.
---

:::u-page-hero
#title
Internal DNS, zero config — containers resolve themselves.

#description
DNS Resolver combines **CoreDNS** and **docker-gen** in a single container. Every `*.your.domain` query resolves to your host IP; Traefik routes by `Host()` header. New containers become resolvable within seconds — no manual DNS edits required.

#links
::::u-button{to="/docs/getting-started/introduction" size="xl" trailing-icon="i-lucide-arrow-right" color="neutral"}
Get Started
::::

::::u-button{to="https://github.com/circle-rd/dns-resolver" target="_blank" size="xl" variant="outline" color="neutral" icon="i-simple-icons-github"}
Star on GitHub
::::
:::

:::u-page-section
#title
Why DNS Resolver?

#features
::::u-page-feature{icon="i-lucide-search" title="Auto container discovery" description="docker-gen watches the Docker socket and rewrites the hosts file on every container start or stop. CoreDNS reloads it automatically."}
::::
::::u-page-feature{icon="i-lucide-globe" title="Wildcard zone" description="Every *.your.domain query resolves to HOST_IP. Pair with Traefik: it inspects the Host() header and routes to the correct container."}
::::
::::u-page-feature{icon="i-lucide-settings-2" title="Environment-only config" description="No Corefile or zone file to maintain. The entrypoint generates both from templates at every container start using your environment variables."}
::::
::::u-page-feature{icon="i-lucide-shield" title="Authoritative or split-horizon" description="DNS_AUTHORITATIVE=true returns NXDOMAIN for unknowns (default). Set to false for split-horizon: unknown subdomains fall through to your upstream resolver."}
::::
::::u-page-feature{icon="i-lucide-lock" title="ACME DNS-01 support" description="Enable ACME_DNS_ENABLED=true to forward auth.DOMAIN queries to an acme-dns sidecar — enabling DNS-01 certificate issuance without exposing port 80."}
::::
::::u-page-feature{icon="i-lucide-layers" title="Single container, two binaries" description="CoreDNS 1.12 and docker-gen run as sibling processes inside one Alpine container. No orchestration overhead, no shared volumes."}
::::
:::
