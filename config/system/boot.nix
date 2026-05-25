# System-level boot, initrd, and plymouth configuration
{
  config,
  pkgs,
  lib,
  ...
}:

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
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
