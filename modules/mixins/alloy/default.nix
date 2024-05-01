{...}: {
  # see TODO further down
  imports = [../docker];

  environment.etc."alloy/config.alloy" = {
    source = ./config.alloy;
    mode = "0440";
    user = "root";
  };

  # TODO: Replace this once there's an Alloy package merged into Nixpkgs
  # https://github.com/NixOS/nixpkgs/pull/306048
  virtualisation.oci-containers.containers.alloy = {
    autoStart = true;
    image = "grafana/alloy:v1.0.0";

    user = "root";

    ports = [
      "12345:12345"
    ];

    cmd = [
      "run"
      "--server.http.listen-addr=0.0.0.0:12345"
      "--storage.path=/var/lib/alloy/data"
      "--stability.level=public-preview"

      # we give a path to the directory so it loads every file, instead of
      # one config file. this allows us to add extra configuration in other
      # mixins.
      "/etc/alloy"
    ];

    volumes = [
      # Alloy
      "/var/log:/var/log:ro"
      "/etc/alloy:/etc/alloy:ro"

      "/var/lib/alloy/data"

      # Node Exporter
      "/proc:/host/proc:ro"
      "/sys:/host/sys:ro"
      "/run/udev/data:/host/run/udev/data:ro"
      "/:/rootfs:ro"
    ];
  };
}
