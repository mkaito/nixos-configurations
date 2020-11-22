{ inputs, ... }:
{
  imports = [
    "${inputs.dust}/nix/modules/services/dust"
  ];

  services.dust = {
    token = "NTk4OTg4ODA4NzQ2MzAzNTIw.XSe5ZQ.28tcGZ77EAmr05ddsrYj0CGzhtA";
    enable = true;
    logLevel = "info,dust=trace";
  };

  services.postgresql = rec {
    ensureDatabases = [ "dust" ];
    ensureUsers =
      map (db: {
        name = db;
        ensurePermissions = {
          "DATABASE \"${db}\"" = "ALL";
        };
      }) ensureDatabases;
  };
}
