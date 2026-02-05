# graphics configuration
{ pkgs, ... }:
{
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    libva
  ];
}
