let
  toCIDR = prefix: subnet: "${prefix}/${toString subnet}";
in {
  node = rec {
    prefix = "fd10:8::";
    prefixLen = 64;
    cidr = toCIDR prefix prefixLen;
  };
  pod = rec {
    prefix = "fd10:244::";
    prefixLen = 64;
    cidr = toCIDR prefix prefixLen;
  };
  service = rec {
    prefix = "fd10:96::";
    prefixLen = 108;
    cidr = toCIDR prefix prefixLen;
  };
}
