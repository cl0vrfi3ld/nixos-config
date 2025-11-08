# system-level fonts config
{ config, pkgs, ... }:

{
  
 
  # Enable networking with iwd
  networking.networkmanager.wifi.backend = "iwd";
  networking.wireless.iwd.enable = true;
  iwd-provisioning.enable = true;
  iwd-provisioning.eduroam.enable = true;
  iwd-provisioning.eduroam = {
    domain = "uvm.edu";
    username = "mlevens";
    passwordPath = config.sops.secrets."iwd/eduroam/passwd".path;
    # serverDomainMask = "radius";
  };
  networking.wireless.iwd.settings = {
    Network = {
      EnableIPv6 = true;
    };
    Settings = {
      AutoConnect = true;
    };
  };
}
