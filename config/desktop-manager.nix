{ config, pkgs, ... }:

{
  # Configure the Desktop Manager
  services.desktopManager.plasma6 = {
    enable = true;
    waylandSession = true; # Ensure Wayland session is used
  };
}
