{ config, pkgs, ... }:

{
  # Configure the Desktop Manager
  services.desktopManager.plasma6 = {
    enable = true;
  };
}
