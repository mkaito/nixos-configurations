{
  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces."enp35s0".ipv4.addresses = [
    {
      address = "135.181.74.221";
      prefixLength = 24;
    }
  ];
  networking.interfaces."enp35s0".ipv6.addresses = [
    {
      address = "2a01:4f9:4b:12e2::1";
      prefixLength = 64;
    }
  ];

  networking = {
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    hostName = "stargazer";
    domain = "mkaito.net";
    defaultGateway = "135.181.74.193";
    defaultGateway6 = { address = "fe80::1"; interface = "enp35s0"; };
  };
}
