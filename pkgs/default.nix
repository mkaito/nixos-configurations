inputs: final: prev: let
  inherit (final) callPackage;
  factorio = callPackage ./factorio;
in rec {
  factorio-headless = factorio {releaseType = "headless";};
  factorio-headless-experimental = factorio {
    releaseType = "headless";
    experimental = true;
  };
}
