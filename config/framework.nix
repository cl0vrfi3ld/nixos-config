# framework specific stuff
{ config, pkgs, ... }:
{
  # framework uses the Linux Vendor Firmware Service (LVFS), so we use `fwupd` to easily manage firmware upates
  services.fwupd.enable = true;

  # framework laptop kernel module
  hardware.framework.enableKmod = true;
}