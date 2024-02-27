with import <nixpkgs> {};

pkgs.mkShell {
  buildInputs = [
    direnv
    go-task
    kubectl
    talosctl
  ];
}

