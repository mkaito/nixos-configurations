{ sshKeys, ... }:
{
  imports = [./../modules/services/factorio];

  services.factorio = {
    enable = true;
    whitelist = [ "mkaito" "faore" ];
    rsync = true;
    rsyncKeys = builtins.concatLists (builtins.attrValues sshKeys);
    autoStart = true;
    game-name = "Derptorio 1.1 Vanilla+ Server";
    description = "1.1 Trains & Chill";
    extraSettings.admins = ["mkaito"];
  };

  # Backup game saves
  # Do not backup mods
  services.borgbackup.jobs.backup.paths = [
    "/var/lib/factorio/saves"
  ];
}
