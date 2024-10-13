{
  description = "Dornhaus home lab";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    devenv.url = "github:cachix/devenv";
    flake-parts.url = "github:hercules-ci/flake-parts";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-devenv.url = "github:cachix/devenv-nixpkgs/rolling";

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
    nixpkgs-devenv,
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
        pkgs-devenv = import nixpkgs-devenv {inherit system;};

        talhelper = inputs'.talhelper.packages.default;

        params = {pkgs = pkgs // {inherit talhelper;};};
        talconfig-yaml = import ./talos/talconfig.nix params;
        taskfile-yaml = import ./taskfile.nix params;
      in {
        packages.task-wrapper = pkgs.writeShellScriptBin "task" ''
          ${pkgs.lib.getExe' pkgs-devenv.go-task "task"} --taskfile=${taskfile-yaml} $@
        '';

        devenv.shells.default = {
          name = "homelab";
          devenv.root = let
            devenvRootFileContent = builtins.readFile devenv-root.outPath;
          in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          imports = [
            # https://devenv.sh/guides/using-with-flake-parts/#import-a-devenv-module
          ];

          packages = with pkgs; [
            (wrapHelm kubernetes-helm {
              plugins = with kubernetes-helmPlugins; [
                helm-diff
              ];
            })
            config.packages.task-wrapper

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

          env = {
            TALCONFIG = talconfig-yaml;
            TALSECRET = ./talos/talsecret.sops.yaml;
          };

          enterShell = ''
            export KUBECONFIG=$DEVENV_STATE/talos/kubeconfig
            export TALOSCONFIG=$DEVENV_STATE/talos/talosconfig
          '';
        };
      };
    };
}
