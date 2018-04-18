{ lib, pkgs, config, ... }:
let
  expandUser = name: keys: {
    extraGroups = [ "wheel" ];
    isNormalUser = true;
    openssh.authorizedKeys.keys = keys;
  };
in
{
  imports = [
    ./services/factorio
  ];

  environment.systemPackages = with pkgs; [
    binutils
    dnsutils
    gdb
    git
    htop
    iptables
    ldns
    lsof
    mosh
    ncdu
    rsync
    rxvt_unicode.terminfo
    strace
    sysstat
    tcpdump
    termite.terminfo
    tig
    tmux
    tree
    vim
  ];

  networking.firewall.logRefusedConnections = false; # silence logging of scanners and knockers

  nix.autoOptimiseStore = true; # autodeduplicate files in store

  nixpkgs.overlays = [(import <mkaito/pkgs>)];

  programs.zsh.enable = true;
  programs.mosh.enable = true;

  security.sudo = {
    wheelNeedsPassword = false;
  };

  services.fail2ban = {
    enable = true;
    # Ban repeat offenders longer:
    jails.recidive = ''
      filter = recidive
      action = iptables-allports[name=recidive]
      maxretry = 5
      bantime = 604800 ; 1 week
      findtime = 86400 ; 1 day
    '';
  };

  nix.gc = {
    automatic = true;
    # delete so there is 15GB free, and delete very old generations
    options = ''--max-freed "$((15 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))" --delete-older-than 30d'';
  };

  services.nixosManual.enable = false;

  # Enable Prometheus exporting on all nodes
  # services.prometheus.exporters.node = {
  #   enable = true;
  #   openFirewall = true;
  # };

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  users.mutableUsers = false;
  users.users = (lib.mapAttrs expandUser (import <mkaito/keys/ssh.nix>)) //
  {
    root = { openssh.authorizedKeys.keys = (import <mkaito/keys/ssh.nix>).chris; };
  };

  nixpkgs.config.allowUnfree = true;
}
