export default defineAppConfig({
  ui: {
    colors: {
      primary: "neutral",
    },
  },
  seo: {
    title: "DNS Resolver",
    description:
      "Internal DNS resolver combining CoreDNS and docker-gen — automatic container discovery for private networks.",
  },
  header: {
    title: "DNS Resolver",
  },
  socials: {
    github: "https://github.com/circle-rd/dns-resolver",
  },
  github: {
    url: "https://github.com/circle-rd/dns-resolver",
    branch: "main",
    rootDir: "docs-site",
  },
});
