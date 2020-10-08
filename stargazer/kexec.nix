{ pkgs, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/netboot/netboot-minimal.nix>
    ./network.nix
    ./security.nix
  ];

  environment.systemPackages = with pkgs; [ vim htop ];

  boot.initrd.kernelModules = [
    "dm-snapshot"
    "dm-raid"
  ];
}
