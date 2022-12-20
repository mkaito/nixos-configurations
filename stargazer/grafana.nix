{
  lib,
  pkgs,
  ...
}: {
  services.grafana = {
    enable = true;
    rootUrl = "https://grafana.mkaito.net";
    settings.feature_toggles.enable = "publicDashboards";
  };
}
