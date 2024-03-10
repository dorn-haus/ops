# DH8 Bastion (jump host)

The DH8 Bastion is currently an old Raspberry Pi model B+ running Alpine, with
the following services:

- **SSH server**, for maintenance & remote access.
- **`radvd` server**, to advertise the ULA prefix `fd10:8::` on the local network.
- WireGuard server, to provide IPv6 access from IPv4-only networks. This is
  only used to manually run commands against the cluster, pod traffic is routed
  through the configured interface.
- Squid server, to provide proxy access to IPv4-only container registries.

The Pi B+ only has a 100Mbps network interface, so access to the container
registries is currently somewhat limited. Squid is configured to cache the
images on a 64G µSD card.

## WireGuard config

Decrypt it using the `age.key` file in this repo:

```sh
$ sops --input-type ini --output-type ini --decrypt etc/wiregpard/dh8.sops.conf
```
