# System-level gaming and VR configuration
{
  config,
  pkgs,
  inputs,
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
    # Additional commands before the game starts
    preCommands = ''
      export DXVK_HUD=compiler;
      export MANGO_HUD=1;
    '';
    # # This option is enabled by default
    # #  Configures your system to meet some of the requirements to run star-citizen
    # # Set `vm.max_map_count` default to `16777216` (sysctl(8))
    # #Set `fs.file-max` default to `524288` (sysctl(8))
    # #Also sets `security.pam.loginLimits` to increase hard (limits.conf(5))
    # # Changes outlined in  https://github.com/starcitizen-lug/knowledge-base/wiki/Manual-Installation#prerequisites
    # setLimits = false;
  };
}
