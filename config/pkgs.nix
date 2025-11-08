# system-level flatpak config
{ config, pkgs, ... }:

{
  # List of packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    micro
    age
    direnv
    wget
    easyeffects
    ghostty
    distrobox
    webkitgtk_4_1
    ffmpeg
    bitwarden-desktop
  ];

}
