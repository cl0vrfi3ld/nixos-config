{
  config,
  pkgs,
  lib,
  ...
}:
let
  # disable certain advanced features to improve network compatibility.
  # useful if captive portals aren't resolving
  networkCompatibilityMode = false;
  
  nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
    "8.8.8.8"
  ];
in
lib.mkMerge [
  {
    networking.hostName = "TheUnreliable"; # Define your hostname.
  
    networking.networkmanager.enable = true;

    # Prevent boot delay by not waiting for network connection
    systemd.services.NetworkManager-wait-online.enable = false;

    networking.nftables.enable = true;

    # enable dhcp for wlan0
    networking.interfaces.wlan0.useDHCP = lib.mkDefault true;
  }
  # disable the following features in compat mode
  (lib.mkIf (!networkCompatibilityMode) {
    networking.nameservers = nameservers;
    /*
      evaluation warning: The option `services.resolved.dnsovertls' has been renamed to `services.resolved.settings.Resolve.DNSOverTLS'.
      evaluation warning: The option `services.resolved.dnssec' has been renamed to `services.resolved.settings.Resolve.DNSSEC'.
      evaluation warning: The option `services.resolved.domains'has been renamed to `services.resolved.settings.Resolve.Domains'.
     */
    services.resolved.enable = true;
    services.resolved.settings.Resolve = {
      DNSSEC = "true";
      Domains = nameservers;
      DNSOverTLS = "true";
    };
  })
]
