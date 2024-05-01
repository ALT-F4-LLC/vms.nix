{ lib, ... }:
{
  imports = [ ../alloy ];

  # Only change from normal Alloy mixin is an overridden config file
  environment.etc."alloy/config.alloy".source = lib.mkForce ./config.alloy;

  virtualisation.oci-containers.containers.alloy = {
    environmentFiles = [ "/run/keys/grafana-cloud" ];

    environment = {
      GRAFANA_CLOUD_STACK = "altf4llc";
    };
  };
}
