{sshKeys, ...}: {
  services.gitolite = {
    enable = true;
    adminPubkey = builtins.head sshKeys.chris;
    user = "git";
  };

  # Backup all git repos
  services.borgbackup.jobs.backup.paths = ["/var/lib/gitolite/repositories"];
}
