{
  description = "DH8 K8S dev env";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/23.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
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
            (talhelper.packages.${system}.default)
            go-task
            kubectl
            talosctl
          ];
        };
      });
}

