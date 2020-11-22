{ sshKeys, ... }:
{
  imports = [./../modules/services/factorio];

  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues sshKeys);
    autoStart = true;
  };

  # Backup game saves
  # Do not backup mods
  services.borgbackup.jobs.backup.paths = [
    "/var/lib/factorio/saves"
  ];
}
