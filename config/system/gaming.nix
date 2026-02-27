# System-level gaming and VR configuration
{ config, pkgs, inputs, ... }:

{
  # Steam Configuration
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    platformOptimizations.enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  hardware.steam-hardware.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

  # VR Configuration
  programs.alvr = {
    enable = true;
    openFirewall = false;
  };
}
