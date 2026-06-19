# System-level gaming and VR configuration
{
  pkgs,
  inputs,
  system,
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

  # Sunshine config
  services.sunshine = {
    enable = true;
    capSysAdmin = true;
    autoStart = false;
  };

  # Star Citizen config
  programs.rsi-launcher = {
    # Enables the star citizen module
    enable = true;
    location = "/too/Games/rsi-launcher";
    gamescope = {
      enable = false;
      args = [
        "-W 2560"
        "-H 1600"
      ];
    };
    # umu.enable = true;
    # wine = inputs.nix-citizen.packages.${system}.lug-wine-bin;
    package = inputs.nix-citizen.packages.${system}.rsi-launcher.override (prev: {
      hidetray = true;
    });
  };

  # Gaming Packages
  environment.systemPackages = with pkgs; [
    lact
  ];
}
