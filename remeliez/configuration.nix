{ lib, ... }:
{
  imports = [
    <mkaito/modules>
  ];

  ## Configure the factorio server
  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues (import <mkaito/keys/ssh.nix>));
    autoStart = false;
  };
}
