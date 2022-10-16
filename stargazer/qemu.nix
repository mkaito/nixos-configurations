{ pkgs, ... }: {

  # Make libvirtd available on the system
  virtualisation.libvirtd = {
    enable = true;
    qemu.package = pkgs.qemu_kvm;
    allowedBridges = [ "virbr1" ];
  };

  boot.kernelModules = [ "kvm-amd" ];

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    cloud-utils
  ];
}
