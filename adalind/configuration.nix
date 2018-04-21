{config, pkgs, ...}:
{
  imports = [
    <mkaito/modules>
    <mkaito/adalind/hardware-configuration.nix>
    <mkaito/adalind/packet.nix>
    (builtins.fetchTarball "https://github.com/r-raymond/nixos-mailserver/archive/v2.1.3.tar.gz")
  ];

  networking.firewall.allowedTCPPorts = [
    ## HTTP and HTTPS
    80 443
  ];

  networking.defaultGateway6 = {
    address = "2604:1380:2000:a800::";
    interface = "bond0";
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
    enableImapSsl = true;
  };
}
