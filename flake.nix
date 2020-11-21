{
  description = "Stargazer server configuration";

  inputs = {
    nix.url = "github:NixOS/nix";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

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

    # We only evaluate server configs in the context of the system architecture
    # they are deployed to
    system = "x86_64-linux";
    mkSystem = module: nixosSystem {
      specialArgs = { inherit inputs; };
      inherit system;
      modules = [ module ];
    };
  in
    foldl' recursiveUpdate {} [
       {
        nixosConfigurations.stargazer = mkSystem ./stargazer;

        # Deployment expressions
        deploy.nodes.stargazer = {
          hostname = "stargazer.mkaito.net";
          profiles = {
            system = rec {
              sshUser = "root";
              user = sshUser;
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.stargazer.config.system.build.toplevel;
            };
          };
        };

        # Verify schema of .#deploy
        checks = mapAttrs (_: lib: lib.deployChecks self.deploy) deploy-rs.lib;
      }

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
