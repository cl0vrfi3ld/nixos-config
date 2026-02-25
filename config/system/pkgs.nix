# system-level flatpak config
{ config, pkgs, ... }:

{
  # TODO: organize these into the proper config files
  # List of packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    nixd
    libsecret
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
    unzip
    cachix
    lact
    kdePackages.partitionmanager
  ];
  # allow certain unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "castlabs-electron"
      "antigravity"
      "mathematica"
    ];
}
