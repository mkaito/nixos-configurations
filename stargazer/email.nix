{ config, inputs, ... }:
let
  megabytesToBytes = n: n * 1048576;
  cert = config.security.acme.certs."mkaito.net";
in
{
  imports = [ (import inputs.snm) ];
  mailserver = {
    enable = true;
    fqdn = "stargazer.mkaito.net";
    domains = [ "mkaito.net" "mkaito.com" ];
    messageSizeLimit = megabytesToBytes 50;
    hierarchySeparator = "/";

    loginAccounts = {
      "chris@mkaito.net" = {
        hashedPasswordFile = "/root/secrets/email-hashed-password-mkaito";
        aliases = [
          "chris@mkaito.com"
          "me@mkaito.com"
        ];
      };
      "monitoring@mkaito.net" = {
        hashedPasswordFile = "/root/secrets/email-hashed-password-monitoring";
      };
    };

    # Use our wildcard cert
    certificateScheme = 1;
    certificateFile = "${cert.directory}/fullchain.pem";
    keyFile = "${cert.directory}/key.pem";
  };

  # Increase memory limit
  services.dovecot2.extraConfig = ''
    service imap {
      vsz_limit = 4G
    }
    service quota-status {
      vsz_limit = 4G
    }
  '';

  # Allow Postfix and Dovecot to read ACME certificates
  users.users.${config.services.dovecot2.user}.extraGroups = [ "acme" ];
  users.users.${config.services.postfix.user}.extraGroups = [ "acme" ];

  # Make Postfix and Dovecot reload after renewing ACME certificates
  security.acme.certs."mkaito.net".postRun = ''
    systemctl reload dovecot2
    systemctl reload postfix
  '';

  services.borgbackup.jobs.backup.paths = [
    # Mail store
    "/var/vmail"

    # Redis snapshots
    "/var/lib/redis-rspamd"
  ];

  # Spam filter
  services.redis.servers.rspamd = {
    enable = true;
    bind = "127.0.0.1";
  };

}
