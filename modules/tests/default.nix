{ pkgs, ... }:
{
  alloy = pkgs.callPackage ./alloy/default.nix { };
}
