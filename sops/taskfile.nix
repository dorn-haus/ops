{pkgs, ...}: let
  inherit (pkgs.lib) getExe getExe';

  age-keygen = getExe' pkgs.age "age-keygen";
  sops = getExe pkgs.sops;
  test = getExe' pkgs.coreutils "test";

  ageFile = "$DEVENV_ROOT/age.key";
  ageTest = "${test} -f ${ageFile}";
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "taskfile.yaml" {
    version = 3;

    tasks = {
      age-keygen = {
        desc = "Create a new Age key";
        cmd = "${age-keygen} --output ${ageFile}";
        status = [ageTest];
      };

      age-restore-bw = {
        desc = "Restore the Age key from a Bitwarden vault";
        # NOTE: This uses the system `rbw` binary for compatibility with the agent.
        # To restore the SOPS Age key from Bitwarden, the operator needs to have `rbw` installed.
        cmd = "rbw login && rbw unlock && rbw get home_lab_age_key > ${ageFile}";
        status = [ageTest];
      };

      encrypt-file = {
        internal = true;
        cmd = "${sops} --encrypt --in-place {{.file}}";
        requires.vars = ["file"];
        preconditions = [
          {
            sh = ageTest;
            msg = "SOPS Age key file not found; run age-keygen or age-restore-bw.";
          }
        ];
      };
    };
  }
