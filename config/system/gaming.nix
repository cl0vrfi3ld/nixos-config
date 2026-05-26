# System-level gaming and VR configuration
{
  pkgs,
  ...
}:

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

  # Star Citizen config
  programs.rsi-launcher = {
    # Enables the star citizen module
    enable = true;
    location = "/too/Games/rsi-launcher";
  };

  # Gaming Packages
  environment.systemPackages = with pkgs; [
    lact
  ];
}
