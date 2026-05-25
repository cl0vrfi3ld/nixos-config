# System-level boot, initrd, and plymouth configuration
{
  config,
  pkgs,
  lib,
  ...
}:

let
  # pin kernel to 7.0.6 as its the last known cached kernel
  # that has working bluetooth
  linux_7_0_6 = pkgs.linux_7_0.override {
    argsOverride = rec {
      version = "7.0.6";
      modDirVersion = version;
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/kernel/v7.x/linux-${version}.tar.xz";
        hash = "sha256-y6REQKpXr/18ISQdxbwjSw31PEmfj/w+vCkN0zkKdSM=";
      };
    };
  };
in
{
  # Bootloader setup
  # boot.loader.systemd-boot.enable = true; # Lanzaboote takes over
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.efi.canTouchEfiVariables = true;

  # Secure Boot using Lanzaboote
  environment.systemPackages = [
    pkgs.sbctl
  ];
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  # # Use latest kernel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPackages = pkgs.linuxPackagesFor linux_7_0_6;

  # Enable initrd
  boot.initrd.enable = true;

  # Plymouth splash screen config
  boot.plymouth = {
    enable = true;
    theme = "deus_ex";
    themePackages = with pkgs; [
      (adi1090x-plymouth-themes.override {
        selected_themes = [
          "rings"
          "deus_ex"
        ];
      })
    ];
  };

  # Silence first boot output
  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.initrd.systemd.enable = true;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
  ];

  # Hide the OS choice for bootloaders
  boot.loader.timeout = 0;
}
