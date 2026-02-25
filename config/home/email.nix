{ pkgs, ... }:

{
  home.packages = with pkgs; [
    thunderbird
    protonmail-bridge-gui
  ];
}
