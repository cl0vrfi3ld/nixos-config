{ pkgs, ... }:

{
  home.packages = with pkgs; [
    picard
    chromaprint
    lrcget
    mixxx
    ardour
    tidal-hifi
    feishin
    cavasik
  ];

  
}
