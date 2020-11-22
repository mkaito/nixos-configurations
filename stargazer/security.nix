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

  # Known SSH hostkeys
  programs.ssh.knownHosts = {
    # CI builds
    "github.com" = { publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ=="; };
    "gitlab.com" = { publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9"; };

    # Paganini, PJ Prod
    "[mkaito.com]:30100" = { publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoOiaRNjrX2GTET9eJof1bp2pp2UVBmLy/pyYFYSlaU"; };

    # Backups
    "ch-s010.rsync.net" = { publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKBxDZv64oRMzRkywjmRRrml2pr0XFSZhlL46nUSmM60"; };
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
    enable = true;
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
    email = "chris@mkaito.net";
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
