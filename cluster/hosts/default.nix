{pkgs, ...}: {
  bastion = import ./bastion.nix {inherit pkgs;};
  control_plane = import ./control_plane.nix {inherit pkgs;};
  workers = import ./workers.nix {inherit pkgs;};
}
