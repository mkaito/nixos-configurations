{ lib, inputs, sshKeys, ... }:
let
  inherit (lib) filterAttrs attrValues elem flatten concatStringsSep;
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
        jvmOpts = concatStringsSep " " [
          "-Ddeployment.log=true"
          "-Ddeployment.trace.level=all"
          "-Ddeployment.trace=true"
          "-Dfml.readTimeout=90"
          "-XX:+AggressiveOpts"
          "-XX:+ExplicitGCInvokesConcurrent"
          "-XX:+OptimizeStringConcat"
          "-XX:+UnlockExperimentalVMOptions"
          "-XX:+UseAdaptiveGCBoundary"
          "-XX:+UseConcMarkSweepGC"
          "-XX:+UseFastAccessorMethods"
          "-XX:+UseParNewGC"
          "-XX:GCPauseIntervalMillis=50"
          "-XX:MaxGCPauseMillis=10"
          "-XX:NewRatio=3"
          "-XX:NewSize=84m"
          "-XX:ParallelGCThreads=8"
        ];
        serverConfig = defaults // {
          server-port = 25566;
          motd = "All The Mods 6 - 1.3.3 custom";

          # Nether terrain gen can be very slow
          max-tick-time = 15 * 60 * 1000;
        };
      };
    };
  };
}
