{ inputs, ... }:
{
  imports = [ inputs.dust.module ];
  services.postgresql.ensureDatabases = [ "dust" ];
  services.dust = {
    enable = true;
    environmentFile = "/root/secrets/dust.env";
    profilePath = "/nix/var/nix/profiles/per-user/deploy/dust";
  };
}
