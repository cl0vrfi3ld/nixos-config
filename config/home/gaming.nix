# User-level gaming application configuration
{ pkgs, ... }:

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
  ];
}
