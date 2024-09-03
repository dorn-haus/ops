{pkgs, ...}:
with pkgs.lib; let
  inherit (strings) toIntBase10;
  genIPv6 = import ./ip.nix {inherit pkgs;};
  network = import ../cluster/network.nix;
in
  attrsets.mapAttrsToList (num: mac: let
    inherit (network) node;
    pre4 = builtins.substring 0 (builtins.stringLength node.net4 - 2) node.net4;
    ipv4 = "${pre4}.${toString (toIntBase10 num)}";
    ipv6 = genIPv6 node.net6 mac;
  in {
    inherit ipv4 ipv6 mac;
    hostname = "k8s-${num}";
    net4 = "${ipv4}/${toString node.net4Len}";
    net6 = "${ipv6}/${toString node.net6Len}";
  })
