{ lib, pkgs, ... }:

let
  email.text = ''
    {{ template "__alertmanagerURL" . }}

    {{ range .Alerts }}
      {{ .Labels.severity }}: {{ .Annotations.summary }}
        {{ .Annotations.description }}
      *Details:*
        {{ range .Labels.SortedPairs }} • *{{ .Name }}:* `{{ .Value }}`
        {{ end }}
    {{ end }}
  '';

in
{
  services.prometheus.alertmanager = {
    enable = true;
    webExternalUrl = "https://alertmanager.mkaito.net";
    environmentFile = [ "/root/secrets/alertmanager" ];

    configuration = {
      route = {
        receiver = "email";
        group_wait = "30s";
        group_interval = "5m";
        repeat_interval = "4h";
        group_by = [ "alertname" "job" ];
        routes = [ ];
      };
      receivers = [
        {
          name = "email";
          email_configs = [{
            auth_password = "\${ALERTMANAGER_EMAIL_PASSWORD}";
            to = "chris@mkaito.net";
            from = "monitoring@mkaito.net";
            smarthost = "stargazer.mkaito.net:587";
            auth_username = "monitoring@mkaito.net";
            auth_identity = "monitoring@mkaito.net";
            send_resolved = true;
            text = email.text;
          }];
        }
      ];
    };
  };
}
