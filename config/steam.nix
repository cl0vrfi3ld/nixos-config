{ config, pkgs, ... }:

{
  steam.enable = true;
  steam.extraCompatPackages = with pkgs; [
    proton-ge-bin
  ];
}
