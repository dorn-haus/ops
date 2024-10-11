{pkgs, ...}: let
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "taskfile.yaml" {
    version = 3;

    vars = {
      AGE_FILE = "{{.ROOT_DIR}}/age.key";
      K8S_DIR = "{{.ROOT_DIR}}/k8s";
      KUBECONFIG_FILE = "{{.ROOT_DIR}}/kubeconfig";
      TALOSCONFIG_FILE = "{{.ROOT_DIR}}/talos/clusterconfig/talosconfig)";
    };

    # env = {
    #   KUBECONFIG = "{{.KUBECONFIG_FILE}}";
    #   SOPS_AGE_KEY_FILE = "{{.AGE_FILE}}";
    #   TALOSCONFIG = "{{.TALOSCONFIG_FILE}}";
    # };

    includes = {
      sops = import ./sops.nix {inherit pkgs;};
    };

    tasks.default = {
      desc = "List all tasks";
      cmd = "task --list";
    };
  }
