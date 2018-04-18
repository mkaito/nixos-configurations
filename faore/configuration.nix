{ lib, ... }:
{
  imports = [
    <mkaito/modules>
    ./base-configuration.nix
    ./hardware-configuration.nix
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];

  ## Configure the factorio server
  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues (import <mkaito/keys/ssh.nix>));
    autoStart = true;
  };
}
