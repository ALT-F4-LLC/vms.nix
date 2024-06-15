{ ... }: {
  environment.etc."alloy/config.alloy" = {
    source = ./config.alloy;
    mode = "0440";
    user = "root";
  };

  environment.etc."alloy/base.alloy" = {
    source = ./base.alloy;
    mode = "0440";
    user = "root";
  };

  services.alloy.enable = true;
}
