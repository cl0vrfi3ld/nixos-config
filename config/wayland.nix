# Wayland configuration
{ config, pkgs, lib, ... }:
{
  # Disable X11 windowing system in favor of Wayland
  services.xserver.enable = false;

  # Enable Wayland-specific desktop environments and display managers
  services.displayManager.sddm = {
    # Wayland support for SDDM
    wayland.enable = true;
  };
}