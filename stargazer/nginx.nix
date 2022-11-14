{ pkgs, config, lib, ... }:
let
  domain = "mkaito.net";
in
{
  # Automatically make all vhosts use the pre-generated ACME cert
  imports = [ ./nginx-vhost-ssl.nix ];

  # Nginx module does not do this automatically
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  services.nginx = {
    enable = true;

    # Slightly nicer logs
    commonHttpConfig = ''
      access_log syslog:server=unix:/dev/log,tag=nginx,severity=info combined;
    '';

    # I hope they fixed this
    recommendedProxySettings = true;

    # Serve my file sharing folder
    virtualHosts = {
      files = {
        serverName = "files.stargazer.mkaito.net";
        serverAliases = [ "files.mkaito.net" ];
        locations."/" = {
          root = "/home/chris/public";

          # These files don't ever change once written
          extraConfig = "expires max;";
        };
      };

      grafana = {
        serverName = "grafana.${domain}";
        locations."/".proxyPass = "http://127.0.0.1:3000";
        enableACME = true;
        forceSSL = true;
      };

      prometheus = {
        serverName = "prometheus.${domain}";
        locations."/".proxyPass = "http://127.0.0.1:9090";
        enableACME = true;
        forceSSL = true;
      };

      alertmanager = {
        serverName = "alertmanager.${domain}";
        locations."/".proxyPass = "http://127.0.0.1:9093";
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  users.users.${config.services.nginx.user}.extraGroups = [
    # Serve files from ~/public
    "users"

    # Access ACME certificates
    "acme"
  ];

  # Allow read-only access to home
  systemd.services.nginx.serviceConfig.ProtectHome = "read-only";
  system.activationScripts.traversableHome = ''
    chmod g+x /home/chris
  '';

  # Delete any public files that are older than one year
  systemd.services.cleanup-public-shit = {
    path = with pkgs; [ findutils ];
    script = ''
      find /home/chris/public -type f -mtime +365 -delete
    '';
    startAt = "weekly";
  };
}
