{ lib, inputs, sshKeys, ... }:
let
  inherit (lib) filterAttrs attrValues elem flatten;
  rsyncSSHKeys =
    flatten (attrValues (filterAttrs (n: _: elem n ["chris" "faore"]) sshKeys));
  defaults = {
    white-list = true;
    spawn-protection = 0;
  };
in {
  imports = [ inputs.minecraft-servers.module ];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      e2es = {
        inherit rsyncSSHKeys;
        enable = true;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "4G";
        serverConfig = defaults // {
          motd = "Enigmatica 2: Expert Skyblock";
        };
      };
      atm6 = {
        inherit rsyncSSHKeys;
        enable = true;
        jvmMaxAllocation = "16G";
        jvmInitialAllocation = "8G";
        serverConfig = defaults // {
          server-port = 25566;
          motd = "All The Mods 6";
        };
      };
    };
  };
}
