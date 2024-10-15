{pkgs, ...}:
with pkgs.lib; let
  inherit (strings) toIntBase10;
  genIPv6 = import ./ip.nix {inherit pkgs;};
  cluster = import ../cluster;
in
  attrsets.mapAttrsToList (num: mac: let
    inherit (cluster.network) node;
    pre4 = builtins.substring 0 (builtins.stringLength node.net4 - 2) node.net4;
    ipv4 = "${pre4}.${toString (toIntBase10 num)}";
    ipv6 = genIPv6 node.net6 mac;
  in {
    inherit ipv4 ipv6 mac;
    hostname = "${cluster.name}-${num}";
    net4 = "${ipv4}/${toString node.net4Len}";
    net6 = "${ipv6}/${toString node.net6Len}";
  })
