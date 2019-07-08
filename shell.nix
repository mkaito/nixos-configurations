let
  pkgs = import ./nixpkgs.nix;
  src = builtins.toString ./.;
  stdenv = pkgs.stdenvNoCC;

  overlays = stdenv.mkDerivation {
    name = "nixpkgs-overlays";
    buildCommand = "mkdir -p $out && ln -s ${src}/pkgs $_";
  };
in

stdenv.mkDerivation {
  name = "serokell-ops-env";
  buildInputs = with pkgs; [ nixops gist ];

  NIX_PATH = builtins.concatStringsSep ":" [
    "nixpkgs=${toString pkgs.path}"
    "nixpkgs-overlays=${overlays}"
    "mkaito=${src}"
    "snm=${builtins.toString /home/chris/dev/build/nixos-mailserver}"
    "shaibot=${builtins.toString /home/chris/dev/shaibot}"
  ];
}
