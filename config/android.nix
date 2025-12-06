# android dev config
{ config, pkgs, ... }:
{ 
  # accept sdk license
  nixpkgs.config.android_sdk.accept_license = true;
  # Enable adb
  programs.adb.enable = true;
  # setup user groups
  users.users.coucoucl0vr.extraGroups = [
    "kvm"
    "adbusers"
  ];
  # setup android udev rules (turns out we don't need this)
  # services.udev.packages = [
  #   pkgs.android-udev-rules
  # ];
  # add android studio
  environment.systemPackages = [ pkgs.android-studio-full ];
}
