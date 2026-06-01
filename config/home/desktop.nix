# User-level desktop theming and UI configuration
{ pkgs, ... }:
let
  iconPacks = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme
    kdePackages.breeze-icons
  ];
  # themingDeps = with pkgs; [
  #   kdePackages.qt6ct
  # ];
  utilityApps = with pkgs; [
    kdePackages.okular
    kdePackages.elisa
    kdePackages.gwenview
    kdePackages.ark
  ];
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
    package = pkgs.papirus-icon-theme;
    name = "Papirus";
  };
  # set theming env vars
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
  };
  # add dependencies to home package env
  home.packages = iconPacks ++ utilityApps;

  # desktop config dotfiles
  xdg.configFile = {
    # "niri/config.kdl".source = ../../dotfiles/niri/config.kdl;
    "dolphinrc".source = ../../dotfiles/dolphin/dolphinrc;
  };

  # ensure xdg portals are defined
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    configPackages = [ pkgs.xdg-desktop-portal-gtk ];
    config.common.default = "gtk";
  };
}
