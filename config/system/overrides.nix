# Nixpkgs overrides
{ pkgs, system, inputs, ... }:
# let 
#   inputs.prev-electron-nixpkgs.url = "github:NixOS/nixpkgs/75f3ff834f4b8410b3b0a95765a90c5ad70df9b9";
# in 
{
  nixpkgs.overlays = [
    # currently electron 39 is broken, we pin it to an older version
    (final: prev: {
      # electron_39 = inputs.prev-electron-nixpkgs.legacyPackages.${system}.electron_39;
      # electron = inputs.prev-electron-nixpkgs.legacyPackages.${system}.electron;
    })
  ];
}
