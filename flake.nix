{
  description = "Stargazer server configuration";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    deploy-rs = {
      type = "github";
      owner = "serokell";
      repo = "deploy-rs";
      ref = "mkaito/fix-auto-rollback-flag";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, deploy-rs, ... }@inputs:
  let
    inherit (nixpkgs.lib) foldl' recursiveUpdate nixosSystem mapAttrs;
    mkSystem = module: nixosSystem {
      specialArgs = { inherit inputs; };
      system = "x86_64-linux";
      modules = [ module ];
    };
  in
    foldl' recursiveUpdate {} [
      # Pure outputs
       {
        nixosConfigurations.stargazer = mkSystem ./stargazer;

        # Deployment expressions
        deploy.nodes.stargazer = {
          hostname = "stargazer.mkaito.net";
          profiles = {
            system = rec {
              sshUser = "root";
              user = sshUser;
              path = deploy-rs.lib.x86_64-linux.activate.nixos
                self.nixosConfigurations.stargazer.config.system.build.toplevel;
            };
          };
        };

        # Verify schema of .#deploy
        checks = mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;
      }

      # Per-system outputs
      (flake-utils.lib.eachDefaultSystem (system:
        let
          overlay = import ./pkgs inputs;
          pkgs = nixpkgs.legacyPackages.${system}.extend overlay;

          inherit (pkgs) mkShell;
        in {
          devShell = mkShell {
            buildInputs = with pkgs; [
              # Make sure we have a fresh nix
              nixUnstable

              # deploy tool
              deploy-rs.defaultPackage.${system}
            ];
          };
        }))
    ];
}
