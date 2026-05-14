# User-level gaming application configuration
{
  pkgs,
  inputs,
  system,
  ...
}:

{
  home.packages = with pkgs; [
    prismlauncher
    (heroic.override {
      extraPkgs = pkgs: [
        pkgs.gamescope
        pkgs.proton-ge-bin
      ];
    })
  ];
}
