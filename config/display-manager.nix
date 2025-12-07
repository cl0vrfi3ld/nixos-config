{ config, pkgs, ... }:

{
  # Configure the Display Manager
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true; # Enable Wayland support for SDDM
  };
}
