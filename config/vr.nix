# vrstuff
{ config, pkgs, ... }:
{
  
  programs.alvr = {
    enable = true;
    openFirewall = false;
  };
}
