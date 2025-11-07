# system-level fonts config
{ config, pkgs, ... }:

{

  # Enable networking with iwd
  networking.networkmanager.enable = true;
  # networking.networkmanager.wifi.backend = "iwd";
  # networking.wireless.iwd.enable = true;
  # iwd-provisioning.enable = true;
  iwd-eduroam = {
    enable = true;
    domain = "uvm.edu";
    username = "mlevens";
    passwordHash = "1234";
    serverDomainMask = "radius";
  };
  # networking.wireless.iwd.settings = {
  #   Network = {
  #     EnableIPv6 = true;
  #   };
  #   Settings = {
  #     AutoConnect = true;
  #   };
  # };

}
