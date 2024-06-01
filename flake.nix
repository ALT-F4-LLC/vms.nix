{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixos-generators.url = "github:nix-community/nixos-generators";
    nixos-generators.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:nix-community/srvos";
    srvos.inputs.nixpkgs.follows = "nixpkgs";

    pkgs-nix.url = "github:ALT-F4-LLC/pkgs.nix";
    pkgs-nix.inputs.nixpkgs.follows = "nixpkgs";
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

        packages = import ./nix/images.nix { inherit system inputs; };
      };
    };
}
