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

## 🚧 Under Construction

There is an existing repository where I already have most of these configs,
however it contains various secrets that are not properly extracted out. This
is an attempt to migrate exsting configs and redact any secrets.
