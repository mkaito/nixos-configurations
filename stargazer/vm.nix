{ lib, ... }:
{
  imports = [./server.nix];

  boot.loader.systemd-boot.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "btrfs";
  };

  # Disable all certificates
  security.acme.certs = lib.mkForce {};

  # Does not work without certificates
  mailserver.enable = lib.mkForce false;
  services.nginx.enable = lib.mkForce false;
}
