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

  # Ensure that we have a folder to dump PG backups into
  systemd.tmpfiles.rules = [
    # https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html
    "d /var/lib/backup 0700 -"
  ];

  services.borgbackup.jobs.backup = {
    paths = [
      # Postgres dumps
      "/var/lib/backup"
    ];

    # Need to write here to dump databases
    readWritePaths = [ "/var/lib/backup" ];

    # Dump all databases to a file
    preHook = ''
      /run/wrappers/bin/sudo -u postgres \
      ${config.services.postgresql.package}/bin/pg_dumpall \
      > /var/lib/backup/postgres_dump_$(date -uIm).psql
    '';

    # Delete database dumps after backing up
    postHook = ''
      find /var/lib/backup -iname '*.psql' -delete
    '';
  };
}
