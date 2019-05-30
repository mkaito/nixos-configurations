{config, pkgs, lib, ...}:
with lib;
let
  sshKeys = import <mkaito/keys/ssh.nix>;
in
rec {
  imports = [
    <mkaito/modules>
    <mkaito/adalind/hardware-configuration.nix>
    <mkaito/adalind/packet.nix>
    <snm>
    # (builtins.fetchTarball {
    #   url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/v2.2.0/nixos-mailserver-v2.2.0.tar.gz";
    #   sha256 = "0gqzgy50hgb5zmdjiffaqp277a68564vflfpjvk1gv6079zahksc";
    # })
  ];

  networking.firewall.allowedTCPPorts = [
    ## HTTP and HTTPS
    80 443 2022
  ];

  networking.defaultGateway6 = {
    address = "2604:1380:2000:a800::";
    interface = "bond0";
  };

  services.shaibot.enable = true;

  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" "CrazyNinja7" "Celestar340" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues sshKeys);
    autoStart = true;
  };

  services.openssh.gatewayPorts = "yes";

  services.gitlab-runner = {
    enable = true;
    configFile = "/var/lib/gitlab-runner/config.toml";
    packages = with pkgs; [
      su
      bash
      postgresql_10
    ];
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_10;
    initialScript = pkgs.writeText "pg-init.sql" ''
        CREATE ROLE test WITH LOGIN CREATEDB;
        CREATE ROLE shaibot WITH LOGIN CREATEDB;
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
    commonHttpConfig = ''
      access_log syslog:server=unix:/dev/log,tag=nginx,severity=info combined;
      upstream sinatra {
        server 127.0.0.1:27483 fail_timeout=0;
      }
    '';
    virtualHosts = {
      files = {
        serverName = "files.mkaito.net";
        default = true;
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          root = "/home/chris/public";
        };
      };
      derp = {
        serverName = "derp.mkaito.net";
        enableACME = true;
        forceSSL = true;
        root = "/home/chris/derp";
        locations."/" = {
          tryFiles = "$uri/index.html $uri.html $uri @app";
          extraConfig = ''
            add_header Access-Control-Allow-Origin "*";
          '';
        };
        locations."@app" = {
          proxyPass = "http://sinatra";
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
  mailserver = let
    megabytesToBytes = n: n * 1048576;
  in {
    enable = true;
    fqdn = "adalind.mkaito.net";
    domains = [ "mkaito.net" "mkaito.com" "udsgaming.net" ];
    messageSizeLimit = megabytesToBytes 50;

    loginAccounts = {
      "chris@mkaito.net" = {
        hashedPassword = "$6$XsKtXFVJAF$QjloeO/oFG.eEx9IR..CdBc2KCwpAOg/vHwrNpVWOuXiJ5TBhdNV01TVFt5pUtnmWws1P6TUYDJTSPYHX5QKK1";
        aliases = [
          "@mkaito.net"
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

  services.gitolite = {
    enable = true;
    adminPubkey = builtins.head sshKeys.chris;
    user = "git";
  };

  users.users.root.hashedPassword = "$6$lTBGqUqKYw$sBQXsEfL5FqwYbJlyejWRoagNUjoALM6VCtz7qI6veS.lIluw9cPx8NDmoinWFzS.g8WBuZCQZxs8NTmns/G4/";
  users.users.chris.hashedPassword = "$6$5cT0x8HjQq$CmQt274.cqvOlJM/9M1qTBSlcH19G8iaxHNkFRqMZAUtuhHjDGSkfqb5LEd2C7fQtLpXnUSQWYcZu3qsbRJZr.";

  system.stateVersion = "18.09";
}
