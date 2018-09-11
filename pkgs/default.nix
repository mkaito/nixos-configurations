final: previous:

let
  inherit (final) callPackage;
in
  {
    nixops-git = callPackage ./nixops-git {
      inherit (final.python2Packages) libvirt;
    };
  }
