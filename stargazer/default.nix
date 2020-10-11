{ pkgs, ... }: {
  imports = [
    ./disk.nix
    ./network.nix
    ./security.nix
    ./system.nix
  ];
}
