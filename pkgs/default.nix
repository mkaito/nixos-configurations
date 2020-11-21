inputs:

final: prev:

let
  inherit (final) callPackage;
in rec {
  nixUnstable = inputs.nix.defaultPackage.${final.system};

  factorio = callPackage ./factorio { releaseType = "alpha"; };
  factorio-experimental = factorio.override { releaseType = "alpha"; experimental = true; };
  factorio-headless = factorio.override { releaseType = "headless"; };
  factorio-headless-experimental = factorio.override { releaseType = "headless"; experimental = true; };
}
