{pkgs, ...}:
with pkgs.lib; let
  genIPv6 = import ../../lib/ip.nix {inherit pkgs;};
  network = import ../network.nix;
in
  attrsets.mapAttrsToList (num: mac: {
    inherit mac;
    hostname = "k8s-${num}";
    ipv6 = genIPv6 network.node.prefix mac;
    os = "talos";
  })
  {
    "01" = "ee:8e:b5:6f:41:d2";
    "06" = "46:8a:5b:ca:96:18";
    "07" = "46:37:e6:56:60:0e";
  }
