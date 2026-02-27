{ pkgs, ... }:

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
  home.packages = with pkgs; [
    adwaita-icon-theme
    kdePackages.breeze-icons
  ];

  # xdg.configFile."niri/config.kdl".source = ../../dotfiles/niri/config.kdl;
}
