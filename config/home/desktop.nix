# User-level desktop theming and UI configuration
{ pkgs, ... }:
let
  iconPacks = with pkgs; [
    adwaita-icon-theme
    kdePackages.breeze-icons
  ];
  themingDeps = with pkgs; [ kdePackages.qt6ct ];
  utilityApps = with pkgs; [ kdePackages.okular ];
in
{
  # set cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
  # set icon theme
  gtk.iconTheme = {
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
  };
  # set theming env vars
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
  };
  # add dependencies to home package env
  home.packages = iconPacks ++ themingDeps ++ utilityApps;

  # xdg.configFile."niri/config.kdl".source = ../../dotfiles/niri/config.kdl;
}
