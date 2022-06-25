{ pkgs, lib, inputs, sshKeys, ... }:
let
  inherit (lib) filterAttrs attrValues elem flatten concatStringsSep;
  rsyncSSHKeys =
    flatten (attrValues (filterAttrs (n: _: elem n [ "chris" "camina" ]) sshKeys));

  # "Borrowed" from AllTheMods Discord
  jvmOpts = concatStringsSep " " [
    "-XX:+UseG1GC"
    "-XX:+ParallelRefProcEnabled"
    "-XX:MaxGCPauseMillis=200"
    "-XX:+UnlockExperimentalVMOptions"
    "-XX:+DisableExplicitGC"
    "-XX:+AlwaysPreTouch"
    "-XX:G1NewSizePercent=40"
    "-XX:G1MaxNewSizePercent=50"
    "-XX:G1HeapRegionSize=16M"
    "-XX:G1ReservePercent=15"
    "-XX:G1HeapWastePercent=5"
    "-XX:G1MixedGCCountTarget=4"
    "-XX:InitiatingHeapOccupancyPercent=20"
    "-XX:G1MixedGCLiveThresholdPercent=90"
    "-XX:G1RSetUpdatingPauseTimePercent=5"
    "-XX:SurvivorRatio=32"
    "-XX:+PerfDisableSharedMem"
    "-XX:MaxTenuringThreshold=1"
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
        enable = false;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "2G";
        serverConfig = defaults // {
          motd = "Enigmatica 2: Expert Skyblock";
          extra-options.level-type = "voidworld";
        };
      };
      po3mythic = {
        inherit rsyncSSHKeys jvmOpts;
        enable = true;
        jvmMaxAllocation = "10G";
        jvmInitialAllocation = "4G";
        serverConfig = defaults // {
          server-port = 25571;
          motd = "Project Ozone 3: Mythic Mode";
          extra-options.level-type = "botania-skyblock";
        };
      };
      omnifactory = {
        inherit rsyncSSHKeys jvmOpts;
        enable = false;
        jvmMaxAllocation = "6G";
        jvmInitialAllocation = "2G";
        serverConfig = defaults // {
          server-port = 25568;
          motd = "Omnifactory dev snapshot #658";
          # Factory good. Mobs bad.
          difficulty = 0;

          # Default world, not lost cities
          extra-options.defaultworldgenerator-port = "d644e624-8d6e-11ea-928f-448a5bef204e";
        };
      };
        modhousemadhouse = {
        inherit rsyncSSHKeys jvmOpts;
        enable = true;
        jvmMaxAllocation = "16G";
        jvmInitialAllocation = "4G";
        serverConfig = defaults // {
          server-port = 25572;
          motd = "I hope this works: please";
        };
      };
      
    };
  };
}
