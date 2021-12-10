{ lib, ... }:
let
  inherit (builtins) map;
in {
  # User for deploy-rs
  users.users.deploy = {
    isSystemUser = true;
    useDefaultShell = true;
    group = "deploy";
    openssh.authorizedKeys.keys =
      ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMGdwmaXyjrewrD5Bc6zpEJfzi38FDR5kqUI2rqKNcG6"];
  };

  users.groups.deploy = {};

  # Allow the deploy user to restart certain services
  security.sudo.extraRules =
    let
      mkRestart = name: {
        users = [ "deploy" ];
        commands = [{
          command = "/run/current-system/sw/bin/systemctl restart ${name}";
          options = [ "NOPASSWD" ];
        }];
      };
    in map mkRestart [ "dust" ];
}
