{
  description = "Stargazer server configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (nixpkgs) lib;
    in
      {
        nixosConfigurations.stargazer = lib.nixosSystem {
          specialArgs = { inherit inputs; };
          system = "x86_64-linux";
          modules = [ ./stargazer/default.nix ];
        };

        deploy.nodes.stargazer = {
          hostname = "stargazer.mkaito.net";
          fastConnection = true;
          profiles = {
            system = rec {
              sshUser = "root";
              user = sshUser;
              path = inputs.deploy-rs.lib.x86_64-linux.setActivate self.nixosConfigurations.stargazer.config.system.build.toplevel
                "./bin/switch-to-configuration switch";
            };
          };
        };

        checks = { "x86_64-linux" = { checkSchema = inputs.deploy-rs.lib.x86_64-linux.checkSchema self.deploy; }; };
      };
}
