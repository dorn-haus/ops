inputs @ {pkgs, ...}: let
  inherit (builtins) listToAttrs map;
  cluster = import ../cluster inputs;
  clusterGroup = group:
    listToAttrs (map (value @ {
        hostname,
        ipv4,
        ...
      }: {
        name = hostname;
        value =
          value
          // {
            ansible_host = ipv4;
          };
      })
      group);
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "inventory.yaml" {
    alpine = {
      hosts = clusterGroup cluster.nodes.alpine;
      vars = {
        inherit (cluster) network;
        cluster = {inherit (cluster) domain name;};
      };
    };
  }
