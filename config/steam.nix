{ config, pkgs, ... }:

{
  programs.steam = let
  patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
    patches = (o.patches or []) ++ [
      ./steam_bwrap.patch
    ];
  });
in {
    enable = true;
    package = pkgs.steam.override {
    buildFHSEnv = (args: ((pkgs.buildFHSEnv.override {
      bubblewrap = patchedBwrap;
    }) (args // {
      extraBwrapArgs = (args.extraBwrapArgs or []) ++ [ "--cap-add ALL" ];
    })));
  };
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server};
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };
  hardware.steam-hardware.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;

}
