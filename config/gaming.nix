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
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    platformOptimizations.enable = true;
    extraCompatPackages = with pkgs; [
      # inputs.nix-gaming.packages.${pkgs.system}.proton-ge
      proton-ge-bin
    ];
  };
  hardware.steam-hardware.enable = true;
  programs.gamescope = {
    enable = true;
    # capSysNice = true;
  };
  programs.gamemode.enable = true;

  # DualSense Controller Configuration
  services.udev.extraRules = ''
    # PS5 DualSense controller over USB hidraw
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ce6", MODE="0660", TAG+="uaccess"

    # PS5 DualSense controller over bluetooth hidraw
    KERNEL=="hidraw*", KERNELS=="*054C:0CE6*", MODE="0660", TAG+="uaccess"

    # PS5 DualSense Edge controller over USB hidraw
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"

    # PS5 DualSense Edge controller over bluetooth hidraw
    KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
  '';
}
