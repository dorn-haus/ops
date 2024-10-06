{pkgs, ...}: let
  inherit (pkgs.lib.generators) toYAML;

  cluster = import ../cluster;
  hosts = import ../cluster/hosts {inherit pkgs;};
  writeYAML = (pkgs.formats.yaml {}).generate;

  first = builtins.head hosts.control_plane;
in
  writeYAML "talconfig.yaml" {
    clusterName = cluster.name;
    talosVersion = "v1.8.0";
    kubernetesVersion = "v1.31.1";
    endpoint = "https://${first.ipv4}:6443";
    domain = cluster.domain;

    # Allow running jobs on control plane nodes.
    # Currently the control plane nodes don't do much anyway.
    allowSchedulingOnControlPlanes = true;

    nodes =
      map (node: {
        inherit (node) hostname;
        ipAddress = node.ipv4;
        controlPlane = true;
        installDiskSelector.type = "ssd";
        networkInterfaces = [
          {
            deviceSelector.hardwareAddr = "*";
            dhcp = true;
          }
        ];
      })
      hosts.control_plane;

    patches = [
      (toYAML {} {
        cluster = {
          network = with cluster.network; {
            podSubnets = with pod; [cidr4 cidr6];
            serviceSubnets = with service; [cidr4 cidr6];
            # cni = {name = "none";}; # cilium
          };
        };
      })
    ];
  }
