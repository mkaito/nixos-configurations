{
  config,
  lib,
  ...
}: let
  inherit (lib) optionalAttrs mkOption mapAttrs;

  certname = "mkaito.net";
  cert = config.security.acme.certs.${certname};

  overrideVirtualHost = name: vhost:
    vhost
    // {
      forceSSL = true;
    }
    // (optionalAttrs (vhost.enableACME == false) {
      # If the vhost does not use explicit ACME, set SSL file paths.
      sslCertificate = "${cert.directory}/fullchain.pem";
      sslCertificateKey = "${cert.directory}/key.pem";
      sslTrustedCertificate = "${cert.directory}/chain.pem";
    })
    // (optionalAttrs (vhost.serverName == null) {
      # foo => foo.stargazer.mkaito.net
      serverName = "${name}.${config.networking.hostName}.${config.networking.domain}";
    });
in {
  # Override all virtual hosts to use the pregenerated certificate
  options.services.nginx.virtualHosts = mkOption {
    apply = vhosts: mapAttrs overrideVirtualHost vhosts;
  };
}
