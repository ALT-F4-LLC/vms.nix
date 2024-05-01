{...}: {
  services.cachix-agent.enable = true;

  boot.loader.efi.canTouchEfiVariables = true;

  services.openssh.enable = true;

  security.sudo.wheelNeedsPassword = false;

  security.auditd.enable = true;
  security.audit.enable = true;
  security.audit.rules = [
    "-a exit,always -F arch=b64 -S execve"
  ];

  users.users.altf4 = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkhuhfzyg7R+O62XSktHufGmmhy6FNDi/NuPPJt7bI+"
    ];
  };

  system.stateVersion = "24.05";
}
