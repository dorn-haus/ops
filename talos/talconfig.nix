{pkgs, ...}: let
  inherit (pkgs.lib.generators) toYAML;

  cluster = import ../cluster;
  hosts = import ../cluster/hosts {inherit pkgs;};
  writeYAML = (pkgs.formats.yaml {}).generate;

  sans = [
    "::" # api-server
    "::1" # controller-manager, scheduler
  ];
in
  writeYAML "talconfig.yaml" {
    clusterName = cluster.name;
    talosVersion = "v1.7.6";
    kubernetesVersion = "v1.30.2";
    endpoint = "https://${(builtins.head hosts.control_plane).ipv4}:6443";
    domain = cluster.domain;

    # Disable Flannel CNI.
    # This is necessary in order to enable Cilium CNI.
    cniConfig.name = "none";

    additionalMachineCertSans = sans;
    additionalApiServerCertSans = sans;

    # Allow running jobs on control plane nodes.
    # Currently the control plane nodes don't do much anyway.
    allowSchedulingOnControlPlanes = true;

    nodes =
      map (node: {
        inherit (node) hostname;
        ipAddress = "${node.ipv4},${node.ipv6}";
        controlPlane = true;
        installDisk = "/dev/sda";
        networkInterfaces = [
          {
            addresses = with node; [net4 net6];
            deviceSelector.hardwareAddr = "*";
            dhcp = false;
          }
        ];
      })
      hosts.control_plane;

    patches = [
      (toYAML {} {
        cluster = {
          network = with cluster.network; {
            podSubnets = [pod.cidr6];
            serviceSubnets = [service.cidr6];
          };

          # Disable kube-proxy, since we're using
          # Cilium's kube-proxy replacement functionality.
          proxy.disabled = true;

          # Prefer IPv6 all interfaces.
          # TODO: Set up firewall rules to make sure this is not accessible
          # through the external interfaces (via the IPv6 pinholing setup.)
          apiServer.extraArgs.bind-address = "::";
          # Prefer IPv6 loopback for controller-manager and scheduler:
          controllerManager.extraArgs.bind-address = "::1";
          scheduler.extraArgs.bind-address = "::1";
        };
        machine = {
          network = {
            nameservers = [
              "1.1.1.1" # CloudFlare 1
              "8.8.8.8" # Google 1
              "2606:4700:4700::1001" # Cloudflare 2
              "2001:4860:4860::8844" # Google 2
            ];
          };
          # Prevent the kubelet from using any other address range.
          # Otherwise the kubelet might pick the auto-configured ::ffff:0:0/96
          # range, which has no routes configured so requests would fail.
          kubelet.nodeIP.validSubnets = [cluster.network.node.cidr6];
        };
      })
    ];
  }
