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
    net4 = "10.244.0.0";
    net4Len = 16;
    cidr4 = toCIDR net4 net4Len;

    net6 = "fd10:244::";
    net6Len = 64;
    cidr6 = toCIDR net6 net6Len;
  };
  service = rec {
    net4 = "10.96.0.0";
    net4Len = 12;
    cidr4 = toCIDR net4 net4Len;

    net6 = "fd10:96::";
    net6Len = 108;
    cidr6 = toCIDR net6 net6Len;
  };
  uplink = {
    gw4 = "192.168.1.1";
    gw6 = "fe80::924d:4aff:fecc:ef8b";
  };
}
