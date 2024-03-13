{pkgs, ...}:
with pkgs.lib; let
  # Sums a list of integers.
  sum = lists.foldr (a: b: a + b) 0;
  # Splits a string into a list of characters.
  chars = string: lists.filter (char: char != "") (strings.splitString "" string);
  # Base 16 characters.
  base16 = chars "0123456789ABCDEF";

  # Converts a single char to an integer.
  char2int = char: lists.findFirstIndex (x: x == char) null base16;
  # Converts an integer to a single char.
  int2char = int: builtins.head (lists.drop int base16);
in {
  byte = {
    # Parses a pair of hex chars to an int (i.e. a byte).
    # If "pair" contains more than two characters, only the first two will be used.
    parse = pair: let
      ints = map char2int (lists.take 2 (chars (strings.toUpper pair)));
      ints16 = lists.imap0 (i: v:
        if i == 0
        then v * 16
        else v)
      ints;
    in
      sum ints16;
    # Formats a byte to hexadecimal.
    # If bytes is larger than 255, only the lower 8 bits will be formatted.
    fmt = int: strings.toLower "${int2char (int / 16)}${int2char (mod int 16)}";
  };
}
