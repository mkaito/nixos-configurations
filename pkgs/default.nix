inputs:

final: prev:

let
  inherit (final) callPackage;
  factorio = callPackage ./factorio;
in rec {
  nixUnstable = inputs.nix.defaultPackage.${final.system};

  factorio-headless = factorio { releaseType = "headless"; };
  factorio-headless-experimental = factorio { releaseType = "headless"; experimental = true; };
}
