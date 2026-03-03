# User-level desktop theming and UI configuration
{ pkgs, ... }:
let
  iconPacks = with pkgs; [
    papirus-icon-theme
    adwaita-icon-theme
    kdePackages.breeze-icons
  ];
  themingDeps = with pkgs; [
    kdePackages.qt6ct
    kdePackages.qt5compat
  ];
  utilityApps = with pkgs; [
    kdePackages.okular
    kdePackages.elisa
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
  home.packages = iconPacks ++ themingDeps ++ utilityApps;

  # set default apps
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    # make dolphin the default file manager
    "inode/directory" = "org.kde.dolphin.desktop";
    # make okular the default document viewer
    "application/pdf" = "org.kde.okular.desktop";
  };
  
  xdg.configFile = {
    # "niri/config.kdl".source = ../../dotfiles/niri/config.kdl;
    "dolphinrc".source = ../../dotfiles/dolphin/dolphinrc;
    };
}
