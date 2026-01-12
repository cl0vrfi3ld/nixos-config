# power management stuff
{ config, pkgs, ... }:
{
  # power management optimisations
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  services.power-profiles-daemon.enable = true;
}
