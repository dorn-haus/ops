# Home K8s Cluster

> Home IPv6-friendly Flux-managed K8s cluster on Talos+Alpine.

## 📖 Overview

This repository contains Infrastructure as Code (IaC) and GitOps config files
for managing my hobby cluster in the basement. Inspired by popular repos like
[toboshii/home-ops] and [Euvaz/GitOps-Home], with a few addicional
considerations:

[toboshii/home-ops]: https://github.com/toboshii/home-ops
[Euvaz/GitOps-Home]: https://github.com/Euvaz/GitOps-Home

- **🛠️ Unconventional hardware:** As much as I enjoy automating the software
  infrastructure, I also really like building custom hardware to power it all.
  I spend maybe half the time in front of the ⌨️ keyboard and half the time
  using 🪚🪛 power tools.
- **🌳 Low footprint:** All of the nodes are either old machines I am no longer
  using, or used machines I bought for very cheap. Many use passive cooling.
- **6️⃣ IPv6 networking:** The goal is to manage the entire cluster via IPv6, and
  maybe one day disable IPv4 networking entirely.

##  🧑‍💻️ development / operations

The easiest way to get the required dependencies is to have `nix` and `direnv`
configured. Entering the repo will execute the [`.envrc` file], which in turn
will `use flake` to pull in dependencies from the `flake.nix` file.

[`.envrc` file]: https://github.com/attilaolah/ops/blob/main/.envrc

Without `direnv`, one would need to manually run `nix develop` to manually
enter the development shell.

## 6️⃣ IPv6-only networking

Enabling IPv6 tends to work just fine. Disabling IPv4 (as much as possible) is
when things start to go south. There are a surprising number of popular
domains, for example, that don't seem to have AAAA records yet. *I know, WTF,
right?*

At least the following workarounds are necessary:

- **Time Servers**: `time.cloudflare.com` is a decent alternative that supports
  IPv6.
- **DNS (nameservers)**: Again Cloudflare provides fast public IPv6 nameservers:
  `2606:4700:4700::1001` and `2606:4700:4700::1111`.
- **Container registries**: There is a nice summary this comment:
  https://github.com/docker/roadmap/issues/89#issuecomment-772644009. At the
  time of writing, `mirror.gcr.io` seems to be a good alternative.

For Talos, an easy workaround is to enable DHCP during boot and upgrades (or
give the nodes a static IPv4 address and route). SLAAC will still be used for
configuring IPv6 addresses. Once the node is healthy and Cilium is configured,
disable DHCP or remove any manually assigned IPv4 addresses, and the node
should remain operational.

## 🚧 Under Construction

There is an existing repository where I already have most of these configs,
however it contains various secrets that are not properly extracted out. This
is an attempt to migrate exsting configs and redact any secrets.
