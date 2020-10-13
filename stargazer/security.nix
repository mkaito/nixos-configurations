{config, pkgs, lib, ...}:
with lib;
let
  sshKeys = import ./../keys/ssh.nix;

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
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
    gatewayPorts = "yes";
  };

  security.sudo.wheelNeedsPassword = false;

  users.mutableUsers = false;
  users.users = lib.recursiveUpdate (lib.mapAttrs expandUser sshKeys) {
    root = {
      hashedPassword = "$6$lTBGqUqKYw$sBQXsEfL5FqwYbJlyejWRoagNUjoALM6VCtz7qI6veS.lIluw9cPx8NDmoinWFzS.g8WBuZCQZxs8NTmns/G4/";
      openssh.authorizedKeys.keys = sshKeys.chris ++
        # Deployment key used on builds.sr.ht
        #   secret: 04e2a5e7-5c88-45ad-a806-c5d0073343dc
        ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGdwmaXyjrewrD5Bc6zpEJfzi38FDR5kqUI2rqKNcG6"];
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
  };
}
