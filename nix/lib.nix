{ inputs, system }:
rec {
  newImage = modules: format: inputs.nixos-generators.nixosGenerate {
    inherit system format;
    modules = [
      inputs.srvos.nixosModules.server
      ../modules/profiles/common.nix
    ] ++ modules;
    specialArgs = {
      inherit (inputs)
        nixpkgs
        srvos
        pkgs-nix;
    };
  };

  newAmazonImage = modules:
    let
      _modules = [
        inputs.srvos.nixosModules.hardware-amazon
      ] ++ modules;
    in
    newImage _modules "amazon";
}
