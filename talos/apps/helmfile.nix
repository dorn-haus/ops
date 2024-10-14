inputs @ {pkgs, ...}: let
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "helmfile.yaml" {
    repositories = [
      {
        name = "cilium";
        url = "https://helm.cilium.io";
      }
    ];
    releases = [
      {
        name = "cilium";
        namespace = "kube-system";
        chart = "cilium/cilium";
        version = "1.16.2";
        wait = true;
        values = [
          (import ./cilium-values.nix inputs)
        ];
      }
    ];
  }
