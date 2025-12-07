# Wayland configuration
{ config, pkgs, ... }:
{
  # Disable X11 windowing system in favor of Wayland
  services.xserver.enable = false;

}