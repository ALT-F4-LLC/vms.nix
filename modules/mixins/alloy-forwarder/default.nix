{ lib, ... }: {
  imports = [ ../alloy ];

  # Only change from normal Alloy mixin is an overridden config file
  environment.etc."alloy/config.alloy".source = lib.mkForce ./config.alloy;

  networking.firewall.allowedTCPPorts = [
    9090 # Prometheus
    3100 # Loki
    4317 # OTLP/gRPC
    4318 # OTLP/HTTP
  ];

  networking.firewall.allowedUDPPorts = [
    4317 # OTLP/gRPC
  ];

  services.alloy = {
    extraArgs = "--stability.level public-preview";

    environmentFiles = [ "/run/keys/grafana-cloud" ];
    extraEnvironment = {
      GRAFANA_CLOUD_STACK = "altf4llc";
    };
  };
}
