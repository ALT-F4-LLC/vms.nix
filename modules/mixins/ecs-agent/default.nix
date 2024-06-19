{ ... }: {
  imports = [
    ../docker
    ../alloy
  ];

  boot.kernel.sysctl."net.ipv4.conf.all.route_localnet" = 1;

  networking.firewall.logRefusedConnections = true;
  networking.useDHCP = true;

  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp -d 169.254.170.2 --dport 80 -j DNAT --to-destination 127.0.0.1:51679
    iptables -t nat -A OUTPUT -d 169.254.170.2 -p tcp -m tcp --dport 80 -j REDIRECT --to-ports 51679
  '';

  virtualisation.oci-containers.containers.ecs-agent = {
    autoStart = true;
    image = "public.ecr.aws/ecs/amazon-ecs-agent:v1.82.3";

    ports = [
      "51678:51678" # ecs metadata service
      "51680:51680" # prometheus metrics
    ];

    extraOptions = [
      "--net=host"
    ];

    environmentFiles = [ "/run/keys/ecs.config" ];
    environment = {
      ECS_ENABLE_PROMETHEUS_METRICS = "true";
      ECS_LOGLEVEL = "info";
      ECS_DATADIR = "/data";
      ECS_UPDATES_ENABLED = "false";
      ECS_AVAILABLE_LOGGING_DRIVERS = "[\"journald\"]";
      ECS_ENABLE_TASK_IAM_ROLE = "true";
      ECS_ENABLE_SPOT_INSTANCE_DRAINING = "true";
    };

    volumes = [
      "/var/run/docker.sock:/var/run/docker.sock"

      "/var/log/ecs/:/log"
      "/var/lib/ecs/data:/data"
    ];
  };

  # Monitoring
  environment.etc."alloy/ecs-agent.alloy".source = ./config.alloy;
}
