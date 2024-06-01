{ pkgs-nix, pkgs, ... }: {
  imports = [ pkgs-nix.nixosModules.alloy ];

  environment.etc."alloy/config.alloy" = {
    source = ./config.alloy;
    mode = "0440";
    user = "root";
  };

  services.alloy = {
    enable = true;
    package = pkgs-nix.packages.${pkgs.system}.alloy;
    openFirewall = true;
    configPath = "/etc/alloy";
    group = "root";
    user = "root";
  };
}
