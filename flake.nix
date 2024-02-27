{
  description = "DH8 K8S dev env";

  inputs = {
    # renovate: datasource=github-releases depName=NixOS/nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    # renovate: datasource=github-releases depName=numtide/flake-utils
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    # renovate: datasource=github-releases depName=budimanjojo/talhelper
    talhelper.url = "github:budimanjojo/talhelper/v2.3.1";
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
          ];
        };
      });
}

