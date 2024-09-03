{pkgs, ...}:
with pkgs.lib; let
  inherit (strings) toIntBase10;
  genIPv6 = import ../../lib/ip.nix {inherit pkgs;};
  network = import ../network.nix;
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
  {
    "01" = "ee:8e:b5:6f:41:d2";
    "06" = "46:8a:5b:ca:96:18";
    "07" = "46:37:e6:56:60:0e";
  }
