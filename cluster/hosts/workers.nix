{pkgs, ...}:
with pkgs.lib; let
  genIPv6 = import ../../lib/ip.nix {inherit pkgs;};
  network = import ../network.nix;
in
  attrsets.mapAttrsToList (num: mac: {
    inherit mac;
    hostname = "k8s-${num}";
    ipv6 = genIPv6 network.node.prefix mac;
    os = "alpine";
  })
  {
    "02" = "02:80:64:e7:83:0c";
    "03" = "9e:8e:99:e6:48:e0";
    "04" = "02:8c:fa:d1:df:1d";
    "05" = "02:8c:fa:d3:d0:56";
  }
