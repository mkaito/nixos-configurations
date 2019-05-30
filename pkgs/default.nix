super: self:

let
  inherit (super) callPackage;
in rec {
  nixops-git = callPackage ./nixops-git {
    inherit (self.python2Packages) libvirt;
  };

  factorio = callPackage ./factorio { releaseType = "alpha"; };
  factorio-experimental = factorio.override { releaseType = "alpha"; experimental = true; };
  factorio-headless = factorio.override { releaseType = "headless"; };
  factorio-headless-experimental = factorio.override { releaseType = "headless"; experimental = true; };
}
