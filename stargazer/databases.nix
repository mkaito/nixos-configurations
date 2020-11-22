{ pkgs, config, ... }:
{
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_12;

    # For each database in `ensureDatabases`, create a role with full access to
    # it.
    ensureUsers =
      map (db: {
        name = db;
        ensurePermissions = {
          "DATABASE \"${db}\"" = "ALL";
        };
      }) config.services.postgresql.ensureDatabases;
  };
}
