{pkgs, ...}: {
  control_plane = import ./control_plane.nix {inherit pkgs;};
  workers = import ./workers.nix {inherit pkgs;};
}
