# GitHub Actions runner mixin
# In theory, compatible with x86_64-linux and aarch64-linux.
{ pkgs, ... }:
let
  name = "altf4llc-${pkgs.stdenv.system}";
in
{
  imports = [
    ../alloy
    ../docker
  ];

  nix = {
    extraOptions = ''
      min-free = ${toString (5 * 1024 * 1024 * 1024)}
      max-free = ${toString (5 * 1024 * 1024 * 1024)}
      extra-experimental-features = flakes nix-command
    '';
    settings = {
      cores = 4;
      trusted-users = [ "root" "github-runner" ];
    };
  };

  users.groups.github-runner = { };
  users.users.github-runner = {
    group = "github-runner";
    extraGroups = [ "docker" ];
    isNormalUser = true;
    home = "/run/github-runner/${name}";
  };

  services.github-runners.${name} = {
    enable = true;
    name = null;
    url = "https://github.com/ALT-F4-LLC";
    user = "github-runner";
    tokenFile = "/run/keys/github-runner";
    serviceOverrides = {
      ReadWritePaths = [ "/nix/var/nix/profiles/per-user/" ];
      ProtectHome = "tmpfs";
    };

    extraLabels = [ "nixos" "nix" pkgs.stdenv.system ];

    extraPackages = with pkgs; [
      awscli2
      bashInteractive
      bzip2
      cachix
      coreutils-full
      cpio
      curl
      diffutils
      docker
      findutils
      gawk
      getconf
      getent
      gnugrep
      gnupatch
      gnused
      gnutar
      gzip
      jq
      just
      less
      mkpasswd
      ncurses
      netcat
      nixos-rebuild
      openssh
      procps
      stdenv.cc.libc
      time
      util-linux
      which
      xz
      zstd
    ];
  };
}
