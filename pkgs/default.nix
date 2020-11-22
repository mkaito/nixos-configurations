inputs:

final: prev:

let
  inherit (final) callPackage;
in rec {
  nixUnstable = inputs.nix.defaultPackage.${final.system};

  factorio-headless = factorio.override { releaseType = "headless"; };
  factorio-headless-experimental = factorio.override { releaseType = "headless"; experimental = true; };
}
