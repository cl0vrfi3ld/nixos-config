# system-level fonts config
{ config, pkgs, ... }:

{
  # fonts to be installed
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.open-dyslexic
  ];
}
