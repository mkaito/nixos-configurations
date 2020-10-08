{
  imports = [
    <nixpkgs/nixos/modules/profiles/headless.nix>
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" ];
  boot.kernelModules = [ "kvm-amd" ];

  boot.loader = {
    systemd-boot = {
      enable = true;
      editor = false;
    };

    grub = {
      enable = true;
      version = 2;
      device = "nodev";
      efiSupport = true;
      copyKernels = true;
      efiInstallAsRemovable = true;
    };

    efi.canTouchEfiVariables = false;
  };

  system.stateVersion = "20.09";
}
