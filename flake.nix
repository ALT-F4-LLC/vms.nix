{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:numtide/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-linux"];

      perSystem = {
        pkgs,
        system,
        ...
      }: let
        inherit (pkgs) awscli2 just;
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [awscli2 just];
        };

        formatter = pkgs.alejandra;

        packages = {
          gc-fwd = inputs.nixos-generators.nixosGenerate {
            inherit system;
            modules = [
              inputs.srvos.nixosModules.server
              inputs.srvos.nixosModules.hardware-amazon
              ./modules/profiles/common.nix
              ./modules/mixins/gc-fwd
            ];
            format = "amazon"; # ami
          };

          ecs-node = inputs.nixos-generators.nixosGenerate {
            inherit system;
            modules = [
              inputs.srvos.nixosModules.server
              inputs.srvos.nixosModules.hardware-amazon
              ./modules/profiles/common.nix
              ./modules/mixins/ecs-agent
            ];
            format = "amazon"; # ami
          };
        };
      };
    };
}
