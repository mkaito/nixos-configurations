{ config, inputs, ... }:
let
  megabytesToBytes = n: n * 1048576;
  cert = config.security.acme.certs."mkaito.net";
in {
  imports = [(import inputs.snm)];
  mailserver = {
    enable = true;
    fqdn = "stargazer.mkaito.net";
    domains = [ "mkaito.net" "mkaito.com" ];
    messageSizeLimit = megabytesToBytes 50;
    hierarchySeparator = "/";

    loginAccounts = {
      "chris@mkaito.net" = {
        hashedPassword = "$6$XsKtXFVJAF$QjloeO/oFG.eEx9IR..CdBc2KCwpAOg/vHwrNpVWOuXiJ5TBhdNV01TVFt5pUtnmWws1P6TUYDJTSPYHX5QKK1";
        aliases = [
          "chris@mkaito.com"
          "me@mkaito.com"
        ];
      };
    };

    # Use our wildcard cert
    certificateScheme = 1;
    certificateFile = "${cert.directory}/fullchain.pem";
    keyFile = "${cert.directory}/key.pem";
  };

  # Allow Postfix and Dovecot to read ACME certificates
  users.users.${config.services.dovecot2.user}.extraGroups = [ "acme" ];
  users.users.${config.services.postfix.user}.extraGroups = [ "acme" ];

  # Make Postfix and Dovecot reload after renewing ACME certificates
  security.acme.certs."mkaito.net".postRun = ''
    systemctl reload dovecot2
    systemctl reload postfix
  '';
}
