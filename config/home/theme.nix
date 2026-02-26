# aesthetic and theme configs
{ pkgs, ... }:

{ 
  # set cursor theme
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.gnome.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
}
