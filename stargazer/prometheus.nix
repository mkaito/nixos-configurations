{
  lib,
  pkgs,
  ...
}: let
  renderJSON = name: value: pkgs.writeText name (builtins.toJSON value);

  ports = {
    exporters = {
      node = 9100;
      minecraft = {
        sb3 = 19565;
        aryxsb3 = 19566;
        aryxe6 = 19567;
      };
    };
    alertManager = 9093;
    prometheus = 9090;
  };

  # scraping targets
  # syntax: https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config
  prometheusScrapeConfigs = {
    # node exporter
    "node" = {
      static_configs = [
        {
          targets = [
            # Stargazer itself
            "stargazer.localhost:${toString ports.exporters.node}"
          ];
        }
      ];
    };

    # metrics of prometheus itself
    "prometheus" = {
      static_configs = [
        {
          targets = ["stargazer.localhost:${toString ports.prometheus}"];
        }
      ];
    };

    # Minecraft instance metrics
    "minecraft" = {
      static_configs = [
        {
          targets = ["stargazer.localhost:${toString ports.exporters.minecraft.sb3}"];
          labels = {
            modpack = "Stoneblock 3";
            application = "Stoneblock 3";
          };
        }
        {
          targets = ["stargazer.localhost:${toString ports.exporters.minecraft.aryxsb3}"];
          labels = {
            modpack = "Stoneblock 3";
            application = "Aryx Stoneblock 3";
          };
        }
        {
          targets = ["stargazer.localhost:${toString ports.exporters.minecraft.aryxe6}"];
          labels = {
            modpack = "Enigmatica 6";
            application = "Aryx Enigmatica 6";
          };
        }
      ];
    };
  };

  # alerting rules
  # syntax: https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/
  prometheusAlertingRules = {
    "UnitFailed" = {
      expr = "node_systemd_unit_state{state=\"failed\"} == 1";
      for = "5m";
      labels = {severity = "critical";};
      annotations = {
        summary = "Unit {{ $labels.name }} failed.";
        description = "Unit {{ $labels.name }} on instance {{ $labels.instance }} has been down for more than 5 minutes.";
      };
    };

    "InstanceDown" = {
      expr = "up == 0";
      for = "5m";
      labels = {severity = "critical";};
      annotations = {
        summary = "Instance {{ $labels.instance }} down";
        description = "{{ $labels.instance }} of job {{ $labels.job }} has been down for more than 5 minutes.";
      };
    };

    "FSFilling" = {
      expr = "node_filesystem_avail_bytes / node_filesystem_size_bytes < 0.05";
      for = "12h";
      labels = {severity = "critical";};
      annotations = {
        summary = "File system on {{ $labels.instance }} is filling up.";
        description = "File system {{ $labels.mountpoint }} on {{ $labels.instance }} has been over 95% full for over 12 hours.";
      };
    };

    "NodeLoadAverage" = {
      expr = "node_load5{instance=~\".*jupiter.*\"} /scalar(count(count by(cpu) (node_cpu_seconds_total{instance=~\".*jupiter.*\"}))) * 100 > 90";
      for = "8h";
      labels = {severity = "warning";};
      annotations = {
        summary = "Load Average on {{ $labels.instance }}";
        description = "Load Average on {{ $labels.instance }} is more than 90% for 10 minutes";
      };
    };

    "FsSpaceLeft" = {
      expr = "node_filesystem_free_bytes{fstype=~\"xfs|ext4\"} / node_filesystem_size_bytes{fstype=~\"xfs|ext4\"} < 0.1";
      for = "30m";
      labels = {severity = "warning";};
      annotations = {
        summary = "Low free space on {{ $labels.instance }}";
        description = "Less than 10% free space on '{{ $labels.mountpoint }}' {{ $labels.instance }}.";
      };
    };

    "McTPS" = {
      expr = ''rate(mc_server_tick_seconds_bucket{le="0.5"}[2m])'';
      for = "30m";
      labels = {severity = "warning";};
      annotations = {
        summary = "Low TPS on {{ $labels.application }}";
        description = "TPS has been below 15 for 30m or longer on {{ $labels.application }}.";
      };
    };
  };

  alertingRulesFile = renderJSON "rules.yaml" {
    groups = [
      {
        name = "stargazer";
        rules =
          lib.mapAttrsToList
          (name: rule: {alert = name;} // rule)
          prometheusAlertingRules;
      }
    ];
  };
in {
  # add "stargazer.localhost" alias for 127.0.0.1, to see a nice name in prometheus/grafana interfaces
  networking.extraHosts = ''
    127.0.0.1 stargazer.localhost
  '';

  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    extraFlags = [
      "--web.enable-admin-api"
      "--storage.tsdb.retention.time=365d"
    ];

    configText = builtins.toJSON {
      global = {
        scrape_interval = "15s";
      };

      alerting = {
        alertmanagers = [
          {
            static_configs = [
              {
                targets = [
                  "127.0.0.1:${toString ports.alertManager}"
                ];
              }
            ];
          }
        ];
      };

      rule_files = [alertingRulesFile];

      scrape_configs =
        lib.mapAttrsToList
        (name: config: {job_name = name;} // config)
        prometheusScrapeConfigs;
    };
  };
}
