{ config, lib, ... }:
# let
#   cert = config.security.acme.certs."mkaito.net";
# in
{
  services.matrix-synapse = {
    enable = true;

    listeners = [{
      bind_address = "0.0.0.0";
      port = 13748;

      resources = [
        { compress = true;
          names = [ "client" ]; }
        { compress = false;
          names = [ "federation" ]; }
      ];

      type = "http";
      tls = false;
      x_forwarded = true;

    }];

    public_baseurl = "https://matrix.stargazer.mkaito.net";
    server_name = "mkaito.net";

    # TURN public hosts
    turn_uris = [
      "turns:turn.mkaito.net?transport=udp"
      "turns:turn.mkaito.net?transport=tcp"
      "turn:turn.mkaito.net?transport=udp"
      "turn:turn.mkaito.net?transport=tcp"
    ];

    # TURN shared secret & registration shared secret
    extraConfigFiles = [ "/root/secrets/synapse-secrets.yaml" ];
  };

  # Yes, this is horrible, I know.
  system.activationScripts.traversableRoot = ''
    chmod o+x /root
  '';

  # Ensure psql access
  users.users.matrix-synapse.name = lib.mkForce "matrix-synapse";
  services.postgresql.ensureDatabases = [ "matrix-synapse" ];

  # Nginx for HTTPS termination
  services.nginx.virtualHosts.matrix = {
    default = true;

    serverName = "matrix.stargazer.mkaito.net";
    serverAliases = [ "matrix.mkaito.net" "mkaito.net" ];
    locations."/" = { proxyPass = "http://localhost:13748"; };
  };

  ## Coturn VoIP
  networking.firewall.allowedTCPPorts = [ 3478 5349 ];
  networking.firewall.allowedUDPPorts = [ 3478 5349 ];

  # That's a whole lotta UDP ports...
  networking.firewall.allowedUDPPortRanges = [{
    from = 49152;
    to = 65535;
  }];

  services.coturn = {
    enable = true;
    realm = "turn.mkaito.net";
    static-auth-secret-file = "/root/secrets/coturn-static-secret";

    # Breaks eval !?
    # cert = "${cert.directory}/fullchain.pem";
    # pkey = "${cert.directory}/key.pem";
    cert = "/var/lib/acme/mkaito.net/fullchain.pem";
    pkey = "/var/lib/acme/mkaito.net/key.pem";

    # FIXME: Do not hardcode
    listening-ips = [
      "135.181.74.221"
      "2a01:4f9:4b:12e2::2"
    ];
  };

  users.users.turnserver.extraGroups = [ "acme" ];
  security.acme.certs."mkaito.net".postRun = ''
    systemctl restart coturn
  '';
}
