{ lib, inputs, sshKeys, ... }:
let
  inherit (lib) filterAttrs attrValues elem flatten;
  rsyncSSHKeys =
    flatten (attrValues (filterAttrs (n: _: elem n ["chris" "faore"]) sshKeys));
in {
  imports = [ inputs.minecraft-servers.module ];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      e2es = {
        inherit rsyncSSHKeys;
        enable = true;
        jvmMaxAllocation = "6G";
        jvmInitialAllocation = "2G";
        serverConfig = {
          enable-rcon = true;
          white-list = true;
          motd = "Enigmatica 2: Expert Skyblock";
        };
      };
      atm6 = {
        inherit rsyncSSHKeys;
        enable = true;
        jvmMaxAllocation = "6G";
        jvmInitialAllocation = "2G";
        serverConfig = {
          server-port = 25566;
          enable-rcon = true;
          rcon-port = 25576;
          white-list = true;
          motd = "All The Mods 6";
        };
      };
    };
  };
}
