{ lib, pkgs, ... }:

{
  services.grafana = {
    enable = true;
    rootUrl = "https://grafana.mkaito.net";
    extraOptions = {
      FEATURE_TOGGLES_ENABLE = "publicDashboards";
    };
  };
}
