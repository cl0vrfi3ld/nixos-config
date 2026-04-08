# System-level desktop environment and window manager configuration
{
  inputs,
  pkgs,
  system,
  ...
}:
let
  fileManagers = with pkgs; [
    kdePackages.dolphin
    yazi
  ];
  theming-compat = with pkgs; [
    qt6Packages.qt5compat
    qt6Packages.qt6ct
    # or kdePackages.qt6ct
    # or qt6ct
  ];
in
{
  imports = [ inputs.dms-plugin-registry.modules.default ];

  # Wayland Config
  services.xserver.enable = false;

  # Display Manager
  services.displayManager.dms-greeter = {
    enable = true;
    compositor.name = "niri";
  };

  # Niri and DMS Shell dependencies
  nixpkgs.overlays = [
    (final: prev: {
      dms-shell = prev.dms-shell.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or [ ]) ++ [ prev.kdePackages.kimageformats ];
      });
    })
  ];

  environment.systemPackages =
    with pkgs;
    [
      xwayland-satellite
      dgop
    ]
    ++ fileManagers
    ++ theming-compat
    ;

  programs.niri.enable = true;
  programs.dms-shell = {
    enable = true;
    # package = inputs.dms.packages.${system}.default;
    quickshell.package = inputs.quickshell.packages.${system}.default;
    systemd = {
      enable = true;
      restartIfChanged = true;
    };
    enableSystemMonitoring = true;
    enableVPN = true;
    enableDynamicTheming = true;
    enableAudioWavelength = true;
    enableCalendarEvents = true;
    enableClipboardPaste = true;
    plugins = {
      dankBatteryAlerts.enable = true;
      dankKDEConnect.enable = true;
      easyEffects.enable = true;
      niriScreenshot.enable = true;
    };
  };

  programs.dsearch.enable = true;
  services.accounts-daemon.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.droid-sans-mono
    nerd-fonts.fira-code
    nerd-fonts.roboto-mono
    roboto
    nerd-fonts.open-dyslexic
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Shortcuts and Aliases
  environment.shellAliases = {
    # System
    # rebuild = "sudo nixos-rebuild switch --flake .#default";
    # clean = "nix-collect-garbage -d";

    # Navigation
    # ".." = "cd ..";

    # Utilities
    # ll = "ls -lha";
    # grep = "grep --color=auto";
  };
}
