{
  pkgs,
  lib,
  inputs,
  system,
  modulesPath,
  ...
}: {
  imports = [
    "${modulesPath}/profiles/headless.nix"
    inputs.vscode-server.nixosModule
  ];

  nix.gc = {
    automatic = true;
    # Keep 500GB free, and delete very old generations
    options = ''--max-freed "$((500 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))" --delete-older-than 30d'';
  };

  # autodeduplicate files in store
  nix.autoOptimiseStore = true;

  nixpkgs.config.allowUnfree = true;

  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://mkaito.cachix.org"
  ];

  nix.binaryCachePublicKeys = [
    "mkaito.cachix.org-1:ZBzZsgt5hpnsoAuMx3EkbVE6eSyF59L3q4PlG8FnBro="
  ];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
    secret-key-files = /root/cache-priv-key.pem
  '';

  services.vscode-server.enable = true;

  documentation.nixos.enable = false;

  programs.zsh.enable = true;
  programs.mosh.enable = true;

  # Prometheus node exporter
  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = ["systemd"];
    disabledCollectors = ["timex"];
  };

  environment.systemPackages = with pkgs; [
    binutils
    direnv
    dnsutils
    fd
    gdb
    gh
    git
    htop
    iptables
    ldns
    lsof
    mtr
    ncdu
    ripgrep
    rsync
    rxvt-unicode-unwrapped.terminfo
    strace
    sysstat
    tcpdump
    termite.terminfo
    tig
    tmux
    tree
    vim
    wget

    matrix-synapse
  ];

  environment.variables.EDITOR = "vim";

  system.stateVersion = "21.11";
}
