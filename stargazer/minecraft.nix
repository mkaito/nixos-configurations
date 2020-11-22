{pkgs, config, lib, ...}:
let
  sshKeys = import ./../keys/ssh.nix;
  stateDir = "/var/lib/minecraft";
in {

  networking.firewall.allowedUDPPorts = [ 25565 ];
  networking.firewall.allowedTCPPorts = [ 25565 25575 25565 ];

  systemd.services.minecraft-server = {
    description   = "Minecraft Server Service";
    wantedBy      = [ "multi-user.target" ];
    after         = [ "network.target" ];

    path = with pkgs; [ jdk8.jre bash ];
    serviceConfig = {
      ExecStart = lib.mkForce "${stateDir}/start.sh";
      Restart = "always";
      User = "minecraft";
      WorkingDirectory = stateDir;
    };

    # Ensure EULA is accepted
    preStart = let
      eulaFile = builtins.toFile "eula.txt" ''
        # eula.txt managed by NixOS Configuration
        eula=true
      '';
    in ''
        ln -sf ${eulaFile} eula.txt
    '';
  };

  # Rsync module
  users.users.minecraft = let

    ## Run rsync daemon with this module config
    #  A few notes:
    #  * Rsync runs as the `minecraft` user
    #  * We can't chroot because we're not root
    #  * We can't set gid, uid, because we're not root, but we don't need to
    #    either.
    rsyncdConf = pkgs.writeText "rsyncd-minecraft.conf" ''
      log file = ${stateDir}/rsync.log
      [state]
        use chroot = false
        comment = Minecraft server state
        path = ${stateDir}
        read only = false
    '';

    ## Prepend this forced command to all SSH keys
    #  * We force execution of the rsync daemon with the config above
    #  * We prevent any options that might result in unwanted access
    #  * Needs to be one big line, sorry.
    rsyncCmd = ''command="rsync --config=${rsyncdConf} --server --daemon .",no-agent-forwarding,no-port-forwarding,no-user-rc,no-X11-forwarding,no-pty'';
  in {
    description = "Minecraft server service user";
    createHome      = true;
    uid             = config.ids.uids.minecraft;
    home            = stateDir;

    shell = pkgs.bash;
    openssh.authorizedKeys.keys = map (x: rsyncCmd + " " + x) (builtins.concatLists (builtins.attrValues sshKeys));
  };

  # Modded server is expected to have some kind of backup mod.
  # This allows us to not worry about atomicity of files at any given point in
  # time.
  services.borgbackup.jobs.backup.paths = "/var/lib/minecraft/backups";
}
