{ pkgs, ... }: {

  # Make libvirtd available on the system
  virtualisation.libvirtd = {
    enable = true;
    qemuPackage = pkgs.qemu_kvm;
    allowedBridges = [ "br0" ];
  };

  boot.kernelModules = [ "kvm-amd" ];

  environment.systemPackages = with pkgs; [
    virt-manager
    cloud-utils
  ];
}
