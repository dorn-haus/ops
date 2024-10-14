{pkgs, ...}: let
  cluster = import ../../cluster;

  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "cilium-values.yaml" {
    # Use KubePrism.
    # TODO: Should work via IPv6 as well.
    k8sServiceHost = "127.0.0.1";
    k8sServicePort = 7445;

    cgroup = {
      # Mount CGroup at a different location.
      # The default is to mount it at /run/cilium/cgroupv2.
      automount.enabled = false;
      hostRoot = "/sys/fs/cgroup";
    };

    # Enable use of per endpoint routes instead of routing via the cilium_host interface.
    endpointRoutes.enabled = true;

    # Disable Hubble.
    hubble.enabled = false;

    # IP Address Management.
    # TODO: We should be using the default (cluster-scope).
    ipam.mode = "kubernetes";

    # Enable native routing.
    # This can be done because all nodes are on the same L2 network.
    routingMode = "native";
    autoDirectNodeRoutes = true;
    ipv4.enabled = true; # default = true
    ipv6.enabled = true; # default = false
    ipv4NativeRoutingCIDR = cluster.network.pod.cidr4;
    ipv6NativeRoutingCIDR = cluster.network.pod.cidr6;

    # Export metrics on IPv6 addresses.
    kubeProxyReplacementHealthzBindAddr = "[::]:10256";

    # Enable local redirect policy.
    localRedirectPolicy = true;

    # Rollout pods automatically when a config map changes.
    rollOutCiliumPods = true;
    operator = {
      rollOutPods = true;
      # Use a single operator replica.
      # TODO: Add a second one when the nodes are prepared.
      replicas = 1;
    };

    # Required security context capabilities.
    securityContext.capabilities = {
      ciliumAgent = [
        "CHOWN"
        "KILL"
        "NET_ADMIN"
        "NET_RAW"
        "IPC_LOCK"
        "SYS_ADMIN"
        "SYS_RESOURCE"
        "DAC_OVERRIDE"
        "FOWNER"
        "SETGID"
        "SETUID"
      ];
      cleanCiliumState = [
        "NET_ADMIN"
        "SYS_ADMIN"
        "SYS_RESOURCE"
      ];
    };
  }
