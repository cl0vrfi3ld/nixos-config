# android dev config
{ config, pkgs, ... }:
{
  # Enable adb
  programs.adb.enable = true;
  # setup user groups
  users.users.coucoucl0vr.extraGroups = [
    "kvm"
    "adbusers"
  ];
  # setup android udev rules
  services.udev.packages = [
    pkgs.android-udev-rules
  ];
  # add android studio
  environment.systemPackages = [ pkgs.android-studio ];
}
