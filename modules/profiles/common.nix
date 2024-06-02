{...}: {
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
      # format for these: <key> # @<github username>
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDkhuhfzyg7R+O62XSktHufGmmhy6FNDi/NuPPJt7bI+" # @hbjydev
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDEoozwkEkRw4BtbKU8+boF6ixoOiE20cpbi1EXHJqnT3unSF2Jb7nqV+ywVVtRAGMtK5mV8j9smjx0A5/yCJkpNy1hamZC7Xx5WHUWn/M6+Xk6OkHSW9DcCPli+RgiL5ESHVhRJWpC9Vp+afXJBrzXzu1mPcObP9cWiMPCy67pVp1Rh/r7leUdzjAORQFxmynjdh8WleguNU7F1IfaGm4JlSdUxQTSFbJJst03gQSQdHoUxtqvBeEAyj1LhN6t7eY1sDSQpflafoVGYznE3GrPn39qATgT1fCr/ELKRqe+j6d7XEJdcGClcAF23lrZhTiMTkrTortHbi/BGV4jDIzT2OyFrXXjZT8ZBl1z7Bm9h9i0JaVjLdUnGJH8Sc/pBt2PWOM9EOaFuhp8uc2LbjqgCeK1Y/zysbV7U6Qz4ChCMLTm7ccPnXctUc69McLcj5q1Jy28xZOED6biUqg9kSZvLQ84Dlrxy2/MjSwINfFBqEP3AhCRhrmxrtPHBM0BpYHAK7xyJyaHPOXVf0MjhH3jLZ+TKlXbXzNoAvh0jrG6oJnprDCeX9OKPOmsxYZMeuHMswAIh6MAibOlQmDfLGGB5cCCSjc0E05I5hxF1U24neZcg8Yk/kbanoRKwPzJAtR+GVdQ0wJJnTQIpTIi6DVsKniHTC5oA/4biLDd6yPpDw==" # @erikreinert
    ];
  };

  system.stateVersion = "24.05";
}
