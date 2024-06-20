{ ... }: {
  virtualisation.docker.enable = true;
  virtualisation.oci-containers.backend = "docker";

  # Monitoring
  environment.etc."alloy/docker.alloy".source = ./config.alloy;
}
