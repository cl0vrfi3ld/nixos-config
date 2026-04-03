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
  #   })
  # ];

  # RStudio depends on electron 38 which is EOL. I don't have time to submit a PR to upgrade
  # the electron version but I need RStudio for school so we override for now
  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4"
  ];
}
