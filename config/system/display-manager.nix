{ config, pkgs, ... }:

{
  # enable dms greeter
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri"; # Or "hyprland" or "sway"
  };
}
