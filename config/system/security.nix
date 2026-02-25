# security services config
{ config, pkgs, lib, ... }:

{
  security.polkit.enable = true; # enable polkit
  services.gnome.gnome-keyring.enable = true; # use gnome-keyring as secrets backend
}
