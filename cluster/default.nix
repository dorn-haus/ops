inputs: {
  name = "locker";
  domain = "dorn.haus";

  github = {
    owner = "attilaolah";
    repository = "homelab";
  };

  network = import ./network.nix;
  nodes = import ./nodes inputs;
}
