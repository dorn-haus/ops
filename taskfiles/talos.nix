inputs @ {pkgs, ...}: let
  inherit (pkgs.lib) getExe getExe';

  rm = getExe' pkgs.coreutils "rm";
  talhelper = getExe talhelper-wrapper;
  talosctl = getExe pkgs.talosctl;
  yq = getExe pkgs.yq;

  talhelper-wrapper = pkgs.writeShellScriptBin "talhelper" ''
    ${getExe' pkgs.talhelper "talhelper"} --config-file=${talconfig} $@
  '';

  state = "$DEVENV_STATE/talos";
  talconfig = import ../talos/talconfig.nix inputs;
  talsecret = "$DEVENV_ROOT/talos/talsecret.sops.yaml";
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "taskfile.yaml" {
    version = 3;

    tasks = {
      genconfig = {
        desc = "Bootstrap Talos: #1 - generate configs";
        cmds = [
          "${rm} -rf ${state}"
          "${talhelper} genconfig --secret-file=${talsecret} --out-dir=${state}"
        ];
      };

      dashboard = {
        desc = "Show Talos dashboard on the first node";
        cmd = "${talosctl} --nodes=$(${yq} < $TALOSCONFIG '.context as $c | .contexts[$c] | .nodes[0]' -r) dashboard";
      };
    };
  }
