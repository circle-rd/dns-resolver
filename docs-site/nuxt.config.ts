export default defineNuxtConfig({
  extends: ["docus"],
  app: {
    baseURL: process.env.NUXT_APP_BASE_URL ?? "/dns-resolver/",
  },
  site: {
    url: process.env.NUXT_SITE_URL ?? "https://docs.circle-cyber.com/dns-resolver",
  },
  llms: {
    title: "DNS Resolver",
    description:
      "Internal DNS resolver combining CoreDNS and docker-gen — automatic container discovery for private networks.",
    full: {
      title: "DNS Resolver — Complete Documentation",
      description:
        "Complete documentation for DNS Resolver, an internal DNS server that combines CoreDNS and docker-gen to automatically populate DNS entries for running containers and resolve your domain zone to the host IP.",
    },
  },
});
