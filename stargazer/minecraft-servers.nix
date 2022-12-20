{
  pkgs,
  lib,
  inputs,
  sshKeys,
  ...
}: let
  inherit (lib) filterAttrs attrValues elem flatten concatStringsSep;
  rsyncSSHKeys =
    flatten (attrValues (filterAttrs (n: _: elem n ["chris" "camina"]) sshKeys));

  # Pin JRE versions used by instances
  jre8 = pkgs.temurin-bin-8;
  jre17 = pkgs.temurin-bin-17;

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
  imports = [inputs.minecraft-servers.module];
  services.modded-minecraft-servers = {
    eula = true;
    instances = {
      e2es = {
        enable = false;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "2G";
        jvmPackage = jre8;
        serverConfig =
          defaults
          // {
            server-port = 25565;
            rcon-port = 25566;
            motd = "Enigmatica 2: Expert Skyblock";
            extra-options.level-type = "voidworld";
          };
      };

      po3mythic = {
        enable = false;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "10G";
        jvmInitialAllocation = "4G";
        jvmPackage = jre8;
        serverConfig =
          defaults
          // {
            server-port = 25567;
            rcon-port = 25568;
            motd = "Project Ozone 3: Mythic Mode";
            extra-options.level-type = "botania-skyblock";
          };
      };

      omnifactory = {
        enable = false;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "6G";
        jvmInitialAllocation = "2G";
        jvmPackage = jre8;
        serverConfig =
          defaults
          // {
            server-port = 25569;
            rcon-port = 25570;
            motd = "Omnifactory dev snapshot #658";
            # Factory good. Mobs bad.
            difficulty = 0;

            # default world, not lost cities
            extra-options.defaultworldgenerator-port = "d644e624-8d6e-11ea-928f-448a5bef204e";
          };
      };

      aryxe6 = {
        enable = true;
        inherit rsyncSSHKeys jvmOpts;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "2G";
        jvmPackage = jre8;
        serverConfig =
          defaults
          // {
            server-port = 25571;
            rcon-port = 25572;

            motd = "Aryx Enigmatica 6: Terraforged";
            spawn-protection = 64;

            level-seed = "-7983745119197482167";
            level-type = "terraforged";
            generator-settings = "Enigmatica";

            # Let the Discord bot handle it
            # NB: Discord bot is broken
            white-list = true;
          };
      };

      sb3 = {
        enable = true;
        inherit rsyncSSHKeys;
        jvmOpts =
          jvmOpts
          + " "
          + (concatStringsSep " " [
            "-javaagent:log4jfix/Log4jPatcher-1.0.0.jar"
            "@libraries/net/minecraftforge/forge/1.18.2-40.1.84/unix_args.txt"
          ]);
        jvmPackage = jre17;
        jvmMaxAllocation = "6G";
        jvmInitialAllocation = "2G";
        serverConfig =
          defaults
          // {
            server-port = 25573;
            rcon-port = 25574;
            motd = "Stoneblock 3";
          };
      };

      aryxsb3 = {
        enable = true;
        inherit rsyncSSHKeys;
        jvmOpts =
          jvmOpts
          + " "
          + (concatStringsSep " " [
            "-javaagent:log4jfix/Log4jPatcher-1.0.0.jar"
            "@libraries/net/minecraftforge/forge/1.18.2-40.1.84/unix_args.txt"
          ]);
        jvmPackage = jre17;
        jvmMaxAllocation = "8G";
        jvmInitialAllocation = "2G";
        serverConfig =
          defaults
          // {
            server-port = 25575;
            motd = "Aryx Stoneblock 3";
            # Discord plugin should handle this
            white-list = false;
          };
      };
    };
  };
}
