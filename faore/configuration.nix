{ lib, ... }:
{
  imports = [
    <mkaito/modules>
    ./base-configuration.nix
    ./hardware-configuration.nix
  ];

  ## Configure the factorio server
  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" "CrazyNinja7" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues (import <mkaito/keys/ssh.nix>));
    autoStart = true;
  };
}
