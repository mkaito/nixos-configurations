{ ... }:
{
  boot.initrd.kernelModules = [
    "dm-snapshot"
    "dm-raid"
  ];

  boot.initrd.availableKernelModules = [ "nvme" ];

  fileSystems = {
    "/" = {
      device = "/dev/pool/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/9974-085E";
      fsType = "vfat";
    };
  };

  swapDevices = [{
    device = "/dev/pool/swap";
  }];
}
