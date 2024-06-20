{ pkgs, ... }:
pkgs.testers.runNixOSTest {
  name = "alloy-test";

  nodes.machine = { ... }: {
    networking.firewall.allowedTCPPorts = [ 12345 ];
    imports = [ ../../mixins/alloy ];
  };

  testScript = ''
    import time
    machine.wait_for_unit("alloy.service", timeout=10)
    machine.wait_for_open_port(12345, timeout=10)
    machine.succeed("curl http://localhost:12345 | grep -o \"Grafana Alloy\"")
  '';
}
