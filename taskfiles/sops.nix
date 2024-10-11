{pkgs, ...}: let
  writeYAML = (pkgs.formats.yaml {}).generate;
in
  writeYAML "taskfile.yaml" {
    version = 3;

    vars = {
      AGE_FILE = "{{.ROOT_DIR}}/age.key";
      SOPS_CONFIG_FILE = "{{.ROOT_DIR}}/.sops.yaml";
    };

    tasks = {
      age-keygen = {
        desc = "Initialize Age key";
        cmd = "age-keygen --output {{.AGE_FILE}}";
        status = ["test -f {{.AGE_FILE}}"];
      };

      encrypt-file = {
        internal = true;
        cmd = "sops --encrypt --in-place {{.file}}";
        requires = {
          vars = ["file"];
        };
        preconditions = [
          {
            sh = "test -f {{.AGE_FILE}}";
            msg = "Missing Sops age key file";
          }
        ];
      };
    };
  }
