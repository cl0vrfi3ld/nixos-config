# Nixpkgs overrides
{
  pkgs,
  system,
  inputs,
  ...
}:

{
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     zed-editor-fhs = inputs.nixpkgs-latest.legacyPackages.${system}.zed-editor-fhs;
  #   })
  # ];
}
