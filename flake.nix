{
  description = "DH8 K8S dev env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # renovate: datasource=github-releases depName=numtide/flake-utils
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    # TODO: pin when https://github.com/budimanjojo/talhelper/pull/353 is released.
    talhelper.url = "github:budimanjojo/talhelper";
  };

  outputs = { self, nixpkgs, flake-utils, talhelper, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (pkgs.wrapHelm pkgs.kubernetes-helm { plugins = [ pkgs.kubernetes-helmPlugins.helm-diff ]; })
            (talhelper.packages.${system}.default)
            age
            go-task
            helmfile
            kubectl
            sops
            talosctl
            yq
          ];
        };
      });
}

