{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vesktop
    fluffychat
    signal-desktop
    flare
  ];
}
