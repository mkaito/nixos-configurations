{ pkgs, ... }: {
  imports = [
    ./disk.nix
    ./network.nix
    ./security.nix
    ./system.nix
    # ./minecraft.nix
    ./qemu.nix
  ];
}
