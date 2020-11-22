{ sshKeys, ... }:
{
  services.gitolite = {
    enable = true;
    adminPubkey = builtins.head sshKeys.chris;
    user = "git";
  };
}
