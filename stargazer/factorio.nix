let
  sshKeys = import ./../keys/ssh.nix;
in
{
  imports = [./../modules/services/factorio];

  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues sshKeys);
    autoStart = true;
  };
}
