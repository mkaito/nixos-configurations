{
  networking = {
    usePredictableInterfaceNames = false;
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    hostname = "stargazer";
    domain = "mkaito.net";
  };

  systemd.network = {
    enable = true;
    networks."eth0".extraConfig = ''
      [Match]
      Name = eth0
      [Network]
      # Add your own assigned ipv6 subnet here here!
      Address =  2a01:4f9:4b:12e2::/64
      Gateway = fe80::1
      # optionally you can do the same for ipv4 and disable DHCP (networking.dhcpcd.enable = false;)
      # Address =  144.x.x.x/26
      # Gateway = 144.x.x.1
    '';
  };
}
