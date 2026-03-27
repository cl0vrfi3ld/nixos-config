# Nixpkgs overrides
{
  pkgs,
  system,
  inputs,
  ...
}:
# let
#   inputs.prev-electron-nixpkgs.url = "github:NixOS/nixpkgs/75f3ff834f4b8410b3b0a95765a90c5ad70df9b9";
# in
{
  nixpkgs.overlays = [
    (final: prev: {
      # # rstudio depends on electron 38 which is EOL, force v39
      # rstudio = prev.rstudio.override {
      #   electron_38 = prev.electron_39;
      # };
    })
  ];

  # RStudio depends on electron 38 which is EOL. I don't have time to submit a PR to upgrade
  # the electron version but I need RStudio for school so we override for now
  nixpkgs.config.permittedInsecurePackages = [
    "electron-38.8.4"
  ];
}
