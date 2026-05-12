# User-level gaming application configuration
{
  pkgs,
  inputs,
  system,
  ...
}:

{
  home.packages = with pkgs; [
    bottles
    prismlauncher
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.proton-ge-bin
      ];
    })
    inputs.nix-citizen.packages.${system}.rsi-launcher
  ];
}
