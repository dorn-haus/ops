{
  description = "Dornhaus home lab";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container = {
      url = "github:nlewo/nix2container";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";

    # TODO: Use inputs (devenv.yaml)?
    talhelper.url = "github:budimanjojo/talhelper";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs @ {
    self,
    flake-parts,
    devenv-root,
    talhelper,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [inputs.devenv.flakeModule];
      systems = ["x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: let
        talhelper = inputs'.talhelper.packages.default;
        taskfile-yaml = import ./taskfiles {pkgs = pkgs // {inherit talhelper;};};
      in {
        packages = {
          task = pkgs.writeShellScriptBin "task" ''
            ${pkgs.lib.getExe' pkgs.go-task "task"} --taskfile=${taskfile-yaml} $@
          '';
        };

        devenv.shells.default = {
          name = "homelab";
          devenv.root = let
            devenvRootFileContent = builtins.readFile devenv-root.outPath;
          in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          env = {
            # TODO!
          };

          imports = [
            # This is just like the imports in devenv.nix.
            # See https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
            # ./devenv-foo.nix
          ];

          # https://devenv.sh/reference/options/
          packages = with pkgs; [
            (wrapHelm kubernetes-helm {
              plugins = with kubernetes-helmPlugins; [
                helm-diff
              ];
            })
            config.packages.task

            age
            alejandra
            ansible
            cilium-cli
            fluxcd
            helmfile
            jq
            kubectl
            sops
            talhelper
            talosctl
            yq
            yq-go
          ];

          enterShell = ''
            export TALOSCONFIG=$DEVENV_STATE/talos/talosconfig
          '';
        };
      };
    };
}
# {
#   description = "DH8 K8S dev env";
#
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#     flake-utils.url = "github:numtide/flake-utils/v1.0.0";
#     talhelper.url = "github:budimanjojo/talhelper";
#   };
#
#   outputs = {
#     self,
#     nixpkgs,
#     flake-utils,
#     talhelper,
#     ...
#   }:
#     flake-utils.lib.eachDefaultSystem (system: let
#       pkgs = import nixpkgs {inherit system;};
#       talconfig-yaml = import ./talos/talconfig.nix {inherit pkgs;};
#       taskfile-yaml = import ./taskfiles {inherit pkgs;};
#     in {
#       packages = {
#         inherit talconfig-yaml taskfile-yaml;
#       };
#
#       devShells.default = pkgs.mkShell {
#         buildInputs = with pkgs; [
#           (talhelper.packages.${system}.default)
#           (wrapHelm kubernetes-helm {
#             plugins = with kubernetes-helmPlugins; [
#               helm-diff
#             ];
#           })
#
#           (writeShellScriptBin "task" ''
#             ${lib.getExe' go-task "task"} --taskfile=${taskfile-yaml} $@
#           '')
#
#           age
#           alejandra
#           ansible
#           cilium-cli
#           fluxcd
#           helmfile
#           jq
#           kubectl
#           sops
#           talosctl
#           yq-go
#           yq
#         ];
#
#         # TODO: 1
#         shellHook = ''
#           export ROOT_DIR=${self}
#           export TALCONFIG="${talconfig-yaml}"
#         '';
#       };
#     });
# }
#
# DEBUG: 6

