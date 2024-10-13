inputs @ {pkgs, ...}: let
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "taskfile.yaml" {
    version = 3;

    tasks.default = {
      desc = "List all tasks";
      cmd = "task --list";
    };

    includes = {
      sops = import ./sops/taskfile.nix inputs;
      talos = import ./talos/taskfile.nix inputs;
    };
  }
