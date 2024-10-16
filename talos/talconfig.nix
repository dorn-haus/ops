inputs @ {pkgs, ...}: let
  inherit (pkgs.lib.generators) toYAML;

  cluster = import ../cluster inputs;
  writeYAML = (pkgs.formats.yaml {}).generate;

  first = builtins.head cluster.nodes.cplane;
in
  writeYAML "talconfig.yaml" {
    clusterName = cluster.name;
    talosVersion = "v1.8.1";
    kubernetesVersion = "v1.31.1";
    endpoint = "https://${first.ipv4}:6443";
    domain = cluster.domain;

    # Allow running jobs on control plane nodes.
    # Currently the control plane nodes don't do much anyway.
    allowSchedulingOnControlPlanes = true;

    nodes =
      map (node: {
        inherit (node) hostname;
        controlPlane = node.cplane;

        ipAddress = node.ipv4;
        installDiskSelector.type = "ssd";
        networkInterfaces = [
          {
            deviceSelector.hardwareAddr = node.mac;
            addresses = [node.net4];
            routes = [
              {
                network = "0.0.0.0/0";
                gateway = cluster.network.uplink.gw4;
              }
              # IPv6 default route is auto-configured.
            ];
            dhcp = false;
          }
        ];
      })
      cluster.nodes.talos;

    patches = [
      (toYAML {} {
        cluster = {
          network = with cluster.network; {
            podSubnets = with pod; [cidr4 cidr6];
            serviceSubnets = with service; [cidr4 cidr6];
            cni.name = "none"; # we use cilium
          };
          # Use Cilium's KubeProxy replacement.
          proxy.disabled = true;
        };
        # TODO: move to network config!
        machine.network.nameservers = [
          "1.1.1.1"
          "9.9.9.9"
          "2606:4700:4700::1111"
          "2620:fe::fe"
        ];
      })
    ];
  }
