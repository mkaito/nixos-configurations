{ pkgs, lib, ... }:
let
  inherit (builtins) map toString;
  inherit (lib) genAttrs;
in
{
  services.github-runners =
    let
      mkRunner = name: {
        enable = true;
        replace = true;

        tokenFile = "/root/secrets/github-runner-token";
        url = "https://github.com/OnHaven";

        extraLabels = [ "nixos" ];
      };
    in
    genAttrs (map (i: "stargazer-nixos-shell-${toString i}") [ 1 2 3 4 ]) mkRunner;
}
