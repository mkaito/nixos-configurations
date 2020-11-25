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
      ref = "master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Services
    dust.url = "git+https://git.sr.ht/~mkaito/dust";
    snm = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-20.09";
      flake = false;
    };

    minecraft-servers.url = "git+file:///home/chris/dev/nix/nixos-minecraft-servers";
  };

  outputs = { self, nixpkgs, flake-utils, deploy-rs, ... }@inputs:
  let
    inherit (nixpkgs.lib) foldl' recursiveUpdate nixosSystem mapAttrs;

    # We only evaluate server configs in the context of the system architecture
    # they are deployed to
    system = "x86_64-linux";
    mkSystem = module: nixosSystem {
      specialArgs = {
        inherit inputs;
        sshKeys = import ./lib/ssh/users.nix;
      };

      inherit system;
      modules = [ module ./lib/ssh/hostkeys.nix ];
    };
  in
    foldl' recursiveUpdate {} [
      {
        nixosConfigurations.stargazer = mkSystem ./stargazer/hetzner.nix;
        nixosConfigurations.stargazer-vm = mkSystem ./stargazer/vm.nix;

        # Deployment expressions
        deploy.nodes.stargazer = {
          hostname = "stargazer.mkaito.net";
          profiles = {
            system = rec {
              sshUser = "root";
              user = sshUser;
              path = deploy-rs.lib.${system}.activate.nixos
                self.nixosConfigurations.stargazer;
            };
          };
        };

        terraform.dns = let
          inherit (nixpkgs.legacyPackages.${system}) writeText;
          inherit (builtins) toJSON;
          inherit (nixpkgs.lib) filterAttrs mapAttrs' nameValuePair flip;

          server = self.nixosConfigurations.stargazer.config;
          instances = server.services.modded-minecraft-servers.instances;
          enabledInstances = filterAttrs (_: i: i.enable) instances;
          ipv4 = "135.181.74.221";
          ipv6 = "2a01:4f9:4b:12e2::2";

          a_records = flip mapAttrs' enabledInstances
            (n: v: nameValuePair "${n}_a" {
              zone_id = ''''${data.aws_route53_zone.mkaito_net.zone_id}'';
              name = ''${n}.mc.''${data.aws_route53_zone.mkaito_net.name}'';
              type = "A";
              ttl = "60";
              records = [ipv4];
            });
          aaaa_records = flip mapAttrs' enabledInstances
            (n: v: nameValuePair "${n}_aaaa" {
              zone_id = ''''${data.aws_route53_zone.mkaito_net.zone_id}'';
              name = ''${n}.mc.''${data.aws_route53_zone.mkaito_net.name}'';
              type = "AAAA";
              ttl = "60";
              records = [ipv6];
            });
          srv_records = flip mapAttrs' enabledInstances
            (n: v: nameValuePair "${n}_srv" {
              zone_id = ''''${data.aws_route53_zone.mkaito_net.zone_id}'';
              name = ''_minecraft._tcp.${n}.mc.''${data.aws_route53_zone.mkaito_net.name}'';
              type = "SRV";
              ttl = "60";
              records = [ ''0 5 ${toString v.serverConfig.server-port} ${n}.mc.''${data.aws_route53_zone.mkaito_net.name}'' ];
            });
        in writeText "minecraft.tf.json" (toJSON {
          resource = {
            aws_route53_record = a_records // aaaa_records // srv_records;
          };
        });

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

              # NixOS deployment tool
              deploy-rs.defaultPackage.${system}

              # Cloud resources
              (terraform.withPlugins (p: with p; [ aws ]))
            ];
          };
        }))
    ];
}
