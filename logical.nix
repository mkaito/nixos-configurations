{
  network.description = "Gaming servers";
  network.enableRollback = true;
  defaults = import ./modules;

  adalind =
  { lib, config, pkgs, ... }:
  let
    ## Run rsync daemon with this module config
    #  A few notes:
    #  * Rsync runs as the `factorio` user
    #  * We can't chroot because we're not root
    #  * We can't set gid, uid, because we're not root, but we don't need to
    #    either.
    factorioRsyncdConf = pkgs.writeText "rsyncd-factorio.conf" ''
      log file = ${config.services.factorio.stateDir}/rsync.log
      [mods]
        use chroot = false
        comment = Factorio mods folder
        path = /var/lib/factorio/mods
        read only = false
      [saves]
        use chroot = false
        comment = Factorio saves folder
        path = /var/lib/factorio/saves
        read only = false
    '';

    ## Prepend this forced command to all SSH keys
    #  * We force execution of the rsync daemon with the config above
    #  * We prevent any options that might result in unwanted access
    #  * Needs to be one line, sorry.
    factorioRsyncCmd = ''command="rsync --config=${factorioRsyncdConf} --server --daemon .",no-agent-forwarding,no-port-forwarding,no-user-rc,no-X11-forwarding,no-pty'';
  in
  {
    ## Configure the factorio server
    services.factorio = {
      enable = true;
      manualMods = true;
      whitelist = [ "mkaito" "faore" ];
    };

    ## Set things up to rsync mods/saves
    networking.firewall.allowedTCPPorts = [ 873 ];
    users.users.factorio = {
      # rsync expects a shell on the other end
      shell = pkgs.bash;

      # Fancy Lispy code: concat the forced command with the set of known SSH keys
      openssh.authorizedKeys.keys =
        map (x: factorioRsyncCmd + " " + x)
          (builtins.concatLists
            (builtins.attrValues (import ./keys/ssh.nix)));
    };
  };
}
