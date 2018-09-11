{config, pkgs, lib, ...}:
with lib;
{
  imports = [
    <mkaito/modules>
    <mkaito/adalind/hardware-configuration.nix>
    <mkaito/adalind/packet.nix>
    (builtins.fetchTarball "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.1.4/nixos-mailserver-v2.1.4.tar.gz")
  ];

  networking.firewall.allowedTCPPorts = [
    ## HTTP and HTTPS
    80 443 2022
  ];

  networking.defaultGateway6 = {
    address = "2604:1380:2000:a800::";
    interface = "bond0";
  };

  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" "CrazyNinja7" "Celestar340" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues (import <mkaito/keys/ssh.nix>));
    autoStart = true;
  };

  services.openssh.gatewayPorts = "yes";

  services.gitlab-runner = {
    enable = true;
    configFile = "/var/lib/gitlab-runner/config.toml";
    packages = with pkgs; [
      su
      bash
      postgresql100
    ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql100;
    initialScript = pkgs.writeText "pg-init.sql" ''
        CREATE ROLE test WITH LOGIN CREATEDB;
    '';
    authentication = mkForce ''
        # Generated file; do not edit!
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     trust
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
    '';
  };

  services.redis = {
    enable = true;
    bind = "127.0.0.1";
  };

  services.nginx = {
    enable = true;
    group = "users";
    virtualHosts = {
      "files.mkaito.net" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/home/chris/public";
        };
      };
    };
  };

  ## IRC Bouncer
  services.znc = {
    enable = true;
    mutable = false;
    openFirewall = true;
    confOptions = {
      userName = "chris";
      nick = "mkaito";
      passBlock = ''
        <Pass password>
                Method = sha256
                Hash = 2b90c7083ead25fc0dc579e271aadcf5e602794681628668cfaa9edbdaecd378
                Salt = i,XnYtW*nTR(A!j;W_!a
        </Pass>
      '';
      networks = {
        freenode = {
          channels = [ "#starcraft" "nixos" "#linux" "afewmail" "ruby" "weechat" ];
          server = "irc.freenode.net";
          port = 7000;
          modules = [ "chansaver" "keepnick" "nickserv TDHHbEvoA8efYveD" "route_replies" ];
          extraConf = ''
            FloodBurst = 4
            FloodRate = 1.00
            IRCConnectEnabled = true
            Ident = kaito
            RealName = kaito
          '';
        };
      };
    };
  };

  # Mail server
  mailserver = {
    enable = true;
    fqdn = "adalind.mkaito.net";
    domains = [ "mkaito.net" "mkaito.com" "udsgaming.net" ];

    loginAccounts = {
      "chris@mkaito.net" = {
        hashedPassword = "$6$XsKtXFVJAF$QjloeO/oFG.eEx9IR..CdBc2KCwpAOg/vHwrNpVWOuXiJ5TBhdNV01TVFt5pUtnmWws1P6TUYDJTSPYHX5QKK1";
        aliases = [
          "chris@mkaito.com"
          "me@mkaito.com"
        ];
      };
    };

    certificateScheme = 3;
    enableImap = true;
    # enableImapSsl = true;
  };

  # Temporary fix for Dovecot 2.3
  security.dhparams = {
    enable = true;
    params = {
      dovecot = 2048;
    };
  };

  services.dovecot2.extraConfig = ''
    ssl_dh = </var/lib/dhparams/dovecot.pem
  '';

  systemd.services.dovecot2.requires = [ "dhparams-gen-dovecot.service" ];
  systemd.services.dovecot2.after = [ "dhparams-gen-dovecot.service" ];

  # Fix rmilter
  services.rmilter = {
    postfix.enable = mkForce false;
  };

  system.nixos.stateVersion = "18.09";
}
