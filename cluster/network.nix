let
  toCIDR = net: len: "${net}/${toString len}";
in {
  node = rec {
    net4 = "192.168.8.0";
    net4Len = 16;
    cidr4 = toCIDR net4 net4Len;

    net6 = "fd10:8::";
    net6Len = 64;
    cidr6 = toCIDR net6 net6Len;
  };
  pod = rec {
    net6 = "fd10:244::";
    net6Len = 64;
    cidr6 = toCIDR net6 net6Len;
  };
  service = rec {
    net6 = "fd10:96::";
    net6Len = 108;
    cidr6 = toCIDR net6 net6Len;
  };
}
