# nh cli stuff
{ config, pkgs, ... }:
{
  environment.sessionVariables = {
    NH_FLAKE = "/home/coucoucl0vr/nixos-config"; 
    NH_ELEVATION_PROGRAM = "${pkgs.systemdUkify}/bin/run0";
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
  };
}
