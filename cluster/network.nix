let
  toCIDR = net: len: "${net}/${toString len}";
in {
  node = rec {
    net4 = "10.8.0.0";
    net4Len = 8;
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
    net6Len = 56;
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

  external = rec {
    net4 = "10.10.0.0";
    net4Len = 16;
    cidr4 = toCIDR net4 net4Len;

    nat = let
      ingress = "10.10.10.10";
    in {
      "80" = ingress;
      "443" = ingress;
    };
  };

  uplink = {
    gw4 = "10.0.0.1";
    gw6 = "fe80::3a35:fbff:fe0d:c7bf";
  };
}
