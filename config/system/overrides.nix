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

  # the current version of `bitwarden-desktop` on the `nixos-unstable` uses
  # an EOL version of electron. this is a temporary override until an
  # updated package gets processed through hydra
  nixpkgs.config.permittedInsecurePackages = [
    "electron-39.8.10"
  ];
}
