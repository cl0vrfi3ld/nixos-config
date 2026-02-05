# system-level fonts config
{ config, pkgs, ... }:

{
  # fonts to be installed
  fonts.packages = with pkgs; [
    # code and mono fonts
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.roboto-mono

    # sans serif fonts
    roboto

    # general-purpose fonts
    nerd-fonts.open-dyslexic
    noto-fonts
    
    # emoji fonts
    noto-fonts-color-emoji
  ];
}
