# power management stuff
{ config, pkgs, ... }:
{
  # power management optimisations
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # ensure conflicting power tools are disabled
  services.tlp.enable = false; 
  powerManagement.powertop.enable = false;

  # add powertop analysis tool to system packages
  environment.systemPackages = with pkgs; [
    powertop
  ];
}
