{
  description = "DH8 K8S dev env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    talhelper.url = "github:budimanjojo/talhelper";
  };

  outputs = {
    nixpkgs,
    flake-utils,
    talhelper,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {inherit system;};
      talconfig-yaml = import ./talos/talconfig.nix {inherit pkgs;};
    in {
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          (talhelper.packages.${system}.default)
          (wrapHelm kubernetes-helm {
            plugins = with kubernetes-helmPlugins; [
              helm-diff
            ];
          })

          age
          alejandra
          ansible
          cilium-cli
          fluxcd
          go-task
          helmfile
          jq
          kubectl
          sops
          talosctl
          yq-go
          yq
        ];

        shellHook = ''
          export TALCONFIG="${talconfig-yaml}"
        '';
      };

      packages = {inherit talconfig-yaml;};
    });
}
