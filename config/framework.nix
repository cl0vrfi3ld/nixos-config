# framework specific stuff
{ config, pkgs, ... }:
{
  # framework laptop kernel modules (integrate hardware features like battery control and LEDs as system devices)
  hardware.framework.enableKmod = true;
}