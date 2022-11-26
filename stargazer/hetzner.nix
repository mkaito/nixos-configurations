{lib, ...}: {
  imports = [
    ./server.nix
    ./hetzner-network.nix
    ./hetzner-disk.nix
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "ahci"];

  boot.loader = {
    systemd-boot.enable = false;

    grub = {
      enable = true;
      devices = ["/dev/nvme0n1" "/dev/nvme1n1"];
      efiSupport = false;
    };
  };

  nix.maxJobs = lib.mkDefault 24;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
}
