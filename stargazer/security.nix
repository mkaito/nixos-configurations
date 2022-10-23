{ config
, pkgs
, lib
, sshKeys
, ...}:
with lib;
let
  expandUser = _name: keys: let
    wheel = [ "chris" "faore" ];
    libvirt = [ "chris" "faore" ];
  in {
    extraGroups =
      (lib.optionals (builtins.elem _name wheel) [ "wheel" ])
      ++ (lib.optionals (builtins.elem _name libvirt) [ "libvirtd" ])
      ++ [ "systemd-journal" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = keys;
  };

in {
  # Defines the deploy user
  imports = [ ./deploy.nix ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    gatewayPorts = "yes";
  };

  security.sudo.wheelNeedsPassword = false;
  nix.trustedUsers = [ "root" "@wheel" ];

  users.mutableUsers = false;
  users.users = lib.recursiveUpdate (lib.mapAttrs expandUser sshKeys) {
    root = {
      hashedPassword = "$6$lTBGqUqKYw$sBQXsEfL5FqwYbJlyejWRoagNUjoALM6VCtz7qI6veS.lIluw9cPx8NDmoinWFzS.g8WBuZCQZxs8NTmns/G4/";
      openssh.authorizedKeys.keys = sshKeys.chris ++
        [
          # Remote builds
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKQu6N8OM7hU105dnLpfeRJqpglaoD515pUhwDafFHpK root@cryptbreaker"
        ];
    };

    chris.hashedPassword = "$6$5cT0x8HjQq$CmQt274.cqvOlJM/9M1qTBSlcH19G8iaxHNkFRqMZAUtuhHjDGSkfqb5LEd2C7fQtLpXnUSQWYcZu3qsbRJZr.";
  };

  services.fail2ban = {
    enable = false;
    # Ban repeat offenders longer:
    jails.recidive = ''
      filter = recidive
      action = iptables-allports[name=recidive]
      maxretry = 5
      bantime = 604800 ; 1 week
      findtime = 86400 ; 1 day
    '';
  };

  security.acme = {
    defaults.email = "chris@mkaito.net";
    acceptTerms = true;

    # Generate a certificate valid for mkaito.net and all its subdomains.
    # Use DNS-01 challenge
    certs."mkaito.net" = {
      dnsProvider = "route53";
      credentialsFile = "/root/secrets/lego.env";

      # Note: A wildcard only covers one level of subdomains
      extraDomainNames = [ "*.mkaito.net" "*.stargazer.mkaito.net" ];

      # Tell nginx to reload the cert
      postRun = "systemctl reload nginx || true";
    };
  };
}
