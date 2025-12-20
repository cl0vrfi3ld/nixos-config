# secure boot config using Lanzaboote!
{ pkgs, lib, ... }:

{
  environment.systemPackages = [
    pkgs.sbctl # used to manage keys
  ];

  boot.loader.systemd-boot.enable = lib.mkForce false; # Lanzaboote takes over

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot"; # where keys will live
  };
}