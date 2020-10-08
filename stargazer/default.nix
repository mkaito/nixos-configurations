{ pkgs, ... }: {
  imports = [
    ./network.nix
    ./security.nix
  ];
}
