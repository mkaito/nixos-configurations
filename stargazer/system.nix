{ pkgs, lib, inputs, ... }: {
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/headless.nix"
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" ];

  boot.loader = {
    systemd-boot.enable = false;

    grub = {
      enable = true;
      devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
      efiSupport = false;
    };
  };

  nix.maxJobs = lib.mkDefault 24;
  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  nix.gc = {
    automatic = true;
    # delete so there is 15GB free, and delete very old generations
    options = ''--max-freed "$((15 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))" --delete-older-than 30d'';
  };

  nix.autoOptimiseStore = true; # autodeduplicate files in store
  nixpkgs.config.allowUnfree = true;

  nix.binaryCaches = [
    "https://cache.nixos.org"
    "https://mkaito.cachix.org"
    "s3://serokell-private-cache?endpoint=s3.eu-central-1.wasabisys.com&profile=serokell-cache-read"
  ];

  nix.binaryCachePublicKeys = [
    "mkaito.cachix.org-1:ZBzZsgt5hpnsoAuMx3EkbVE6eSyF59L3q4PlG8FnBro="
    "serokell-1:aIojg2Vxgv7MkzPJoftOO/I8HKX622sT+c0fjnZBLj0="
  ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      secret-key-files = /root/cache-priv-key.pem
    '';
  };

  documentation.nixos.enable = false;

  programs.zsh.enable = true;
  programs.mosh.enable = true;

  environment.systemPackages = with pkgs; [
    binutils
    dnsutils
    fd
    gdb
    git
    htop
    iptables
    ldns
    lsof
    mtr
    ncdu
    ripgrep
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
    wget
  ];

  system.stateVersion = "20.09";
}
