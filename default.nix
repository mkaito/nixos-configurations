let
  overlay = import ./pkgs {} {};
  nixpkgs = import ./nixpkgs.nix;
  nixpkgs-src = import ./nixpkgs-src.nix;
in
  (nixpkgs.lib.filterAttrs (n: _: builtins.hasAttr n overlay) nixpkgs)
