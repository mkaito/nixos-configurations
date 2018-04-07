final: previous:

let
  inherit (final) callPackage;
in
  {
    factorio-headless = callPackage ./factorio {
      releaseType = "headless";
      inherit (final) libGL libXi libXrandr libXinerama libXcursor libX11 alsaLib;
    };

    nixops-git = callPackage ./nixops-git {
      inherit (final.python2Packages) libvirt;
    };
  }
