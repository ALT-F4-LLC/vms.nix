{ lib, ... }: {
  imports = [ ../alloy ];

  # Only change from normal Alloy mixin is an overridden config file
  environment.etc."alloy/config.alloy".source = lib.mkForce ./config.alloy;

  services.alloy = {
    extraArgs = "--stability.level public-preview";

    environmentFiles = [ "/run/keys/grafana-cloud" ];
    extraEnvironment = {
      GRAFANA_CLOUD_STACK = "altf4llc";
    };
  };
}
