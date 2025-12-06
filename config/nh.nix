# nh cli stuff
{ config, pkgs, ... }:
{
  environment.sessionVariables = {
    FLAKE = "/home/coucoucl0vr/nixos-config"; 
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
  };
}
