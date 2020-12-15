{ lib, inputs, sshKeys, ... }:
let
  inherit (lib) filterAttrs attrValues elem flatten concatStringsSep;
  rsyncSSHKeys =
    flatten (attrValues (filterAttrs (n: _: elem n ["chris"]) sshKeys));

  # "Borrowed" from AllTheMods Discord
  jvmOpts = concatStringsSep " " [
    "-XX:+UseG1GC"
    "-Dsun.rmi.dgc.server.gcInterval=2147483646"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:G1NewSizePercent=20"
    "-XX:MaxGCPauseMillis=50"
    "-XX:G1HeapRegionSize=32M"
  ];

  defaults = {
    # Only people in the Cool Club (tm)
    white-list = true;

    # So I don't have to make everyone op
    spawn-protection = 0;

    # 5 minutes tick timeout, for heavy packs
    max-tick-time = 5 * 60 * 1000;

    # It just ain't modded minecraft without flying around
    allow-flight = true;
  };
in {
  imports = [ inputs.minecraft-servers.module ];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      e2es = {
        inherit rsyncSSHKeys jvmOpts;
        enable = true;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "4G";
        serverConfig = defaults // {
          motd = "Enigmatica 2: Expert Skyblock";
        };
      };
      atm6 = {
        inherit rsyncSSHKeys jvmOpts;
        enable = true;
        jvmMaxAllocation = "16G";
        jvmInitialAllocation = "8G";
        serverConfig = defaults // {
          server-port = 25566;
          motd = "All The Mods 6 - 1.3.3 custom";
        };
      };
      interactions = {
        inherit rsyncSSHKeys jvmOpts;
        enable = true;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "4G";
        serverConfig = defaults // {
          server-port = 25567;
          motd = "FTB Interactions 2.0.9";

          # Fancy skyblock tutorial start
          level-type = "voidworld";
        };
      };
      omnifactory = {
        inherit rsyncSSHKeys jvmOpts;
        enable = true;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "4G";
        serverConfig = defaults // {
          server-port = 25568;
          motd = "Omnifactory dev snapshot #603";
          extra-options = {
            # Default world, not lost cities
            defaultworldgenerator-port = "d644e624-8d6e-11ea-928f-448a5bef204e]";
          };
        };
      };
    };
  };
}
