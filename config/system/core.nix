# System-level core configuration (Nix, users, locale)
{ config, pkgs, ... }:

{
  # Time and Locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # User accounts
  users.users.coucoucl0vr = {
    isNormalUser = true;
    description = "Clover";
    extraGroups = [
      "networkmanager"
      "wheel"
      "podman"
      "kvm"
      "adbusers"
    ];
    shell = pkgs.fish;
  };

  # Nix configuration
  nix.settings = {
    trusted-users = [
      "root"
      "coucoucl0vr"
    ];
    experimental-features = "nix-command flakes";
    sandbox = true;
    show-trace = true;
    auto-optimise-store = true;
    max-jobs = "auto";
    builders-use-substitutes = true;
  };
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    nixd
    git
    micro
    direnv
    wget
    distrobox
    webkitgtk_4_1
    ffmpeg
    unzip
    cachix
  ];

  # Allow specific unfree packages
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "castlabs-electron"
      "antigravity"
      "mathematica"
    ];

  # nh cli stuff
  environment.sessionVariables = {
    NH_FLAKE = "/home/coucoucl0vr/nixos-config";
    NH_ELEVATION_PROGRAM = "${pkgs.systemdUkify}/bin/run0";
  };
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep 3";
  };
}
