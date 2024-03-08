# DH8 Jump Host

This is currently an old Raspberry Pi model B+ running Alpine, with the
following services:

- SSH server, for maintenance.
- WireGuard server, to provide IPv6 access from IPv4-only networks.
- Squid server, to provide access to IPv4-only container registries.

## WireGuard config

Decrypt it using the `age.key` file in this repo:

```sh
$ sops --input-type ini --output-type ini --decrypt etc/wiregpard/dh8.sops.conf
```
