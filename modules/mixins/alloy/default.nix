{ ... }: {
  environment.etc."alloy/config.alloy".source = ./config.alloy;
  environment.etc."alloy/base.alloy".source = ./base.alloy;
  services.alloy.enable = true;
}
