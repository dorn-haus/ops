{
  name = "locker";
  domain = "dorn.haus";

  github = {
    owner = "attilaolah";
    repository = "homelab";
  };

  network = import ./network.nix;
}
