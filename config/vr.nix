# vrstuff
{ config, pkgs, ... }:
{
  
  programs.alvr = {
    enable = true;
    openFirewall = true;
  };
}
