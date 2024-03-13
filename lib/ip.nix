{pkgs, ...}: prefix: mac:
with pkgs.lib; let
  hexb = (import ./hex.nix {inherit pkgs;}).byte;

  # Parses MAC address bytes from hexadecimal.
  macb = map (byte: hexb.parse byte) (strings.splitString ":" mac);

  # Inverts the 7th bit of the first byte to indicate the globally unique/local bit.
  macb0 = builtins.head macb;
  eui64b =
    if mod (macb0 / 2) 2 == 0
    then macb0 + 2
    else macb0;
  eui64mac = [eui64b] ++ (lists.drop 1 macb);

  # Returns a single byte of the modified MAC address.
  macAt = byte: builtins.head (lists.drop byte eui64mac);
  hexAt = byte: hexb.fmt (macAt byte);
in "${prefix}${hexAt 0}${hexAt 1}:${hexAt 2}ff:fe${hexAt 3}:${hexAt 4}${hexAt 5}"
