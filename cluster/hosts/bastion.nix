# DEPRECATED! To be replaced or removed.
{pkgs, ...}: let
  genIPv6 = import ../../lib/ip.nix {inherit pkgs;};
  network = import ../network.nix;
in rec {
  hostname = "bastion";
  mac = "b8:27:eb:69:d7:02";
  ipv4 = "192.168.4.1";
  ipv6 = genIPv6 network.node.prefix6 mac;
  os = "alpine";
}
