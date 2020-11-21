{
  imports = [
    # System
    ./disk.nix
    ./network.nix
    ./security.nix
    ./system.nix

    # Services
    ./minecraft.nix
    ./nginx.nix
    ./qemu.nix
  ];
}
