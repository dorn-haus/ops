inputs @ {pkgs, ...}: let
  inherit (builtins) elemAt;
  inherit (pkgs.lib.strings) toIntBase10;

  cluster = import ../. inputs;
  lib = import ../../lib inputs;

  toNode = row: let
    num = elemAt row 0;
    mac = elemAt row 1;
    os = elemAt row 2;
    cplane = elemAt row 3;

    inherit (cluster.network) node;
    pre4 = builtins.substring 0 (builtins.stringLength node.net4 - 2) node.net4;
    ipv4 = "${pre4}.${toString (toIntBase10 num)}";
    ipv6 = lib.eui64 node.net6 mac;
  in {
    inherit ipv4 ipv6 mac os cplane;

    hostname = "${cluster.name}-${num}";
    net4 = "${ipv4}/${toString node.net4Len}";
    net6 = "${ipv6}/${toString node.net6Len}";
  };

  all = map toNode (import ./hosts.nix);
  byOS = os: builtins.filter (node: node.os == os) all;
in {
  inherit all;

  cplane = builtins.filter (node: node.cplane) all;

  alpine = byOS "alp";
  talos = byOS "tal";
}
