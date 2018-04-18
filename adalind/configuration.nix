{config, pkgs, ...}:
{
  imports = [
    <mkaito/modules>
    <mkaito/adalind/hardware-configuration.nix>
    <mkaito/adalind/packet.nix>
  ];

  networking.firewall.allowedTCPPorts = [
    ## HTTP and HTTPS
    80 443
  ];

  ## Configure the factorio server
  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues (import <mkaito/keys/ssh.nix>));
    autoStart = false;
  };

  services.nginx = {
    enable = true;
    group = "users";
    virtualHosts = {
      "files.mkaito.net" = {
        enableACME = true;
        forceSSL = true;
        default = true;
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
}
