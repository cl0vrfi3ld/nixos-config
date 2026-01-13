# framework specific stuff
{ config, pkgs, ... }:
{
  # framework uses the Linux Vendor Firmware Service (LVFS), so we use `fwupd` to easily manage firmware upates
  services.fwupd.enable = true;

  # framework laptop kernel modules (integrate hardware features like battery control and LEDs as system devices)
  hardware.framework.enableKmod = true;
}