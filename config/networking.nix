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
    networking.hostName = "theseus"; # Define your hostname.

    networking.networkmanager.enable = true;

    networking.nftables.enable = true;
  }
  # disable the following features in compat mode
  (lib.mkIf (!networkCompatibilityMode) {
    networking.nameservers = nameservers;

    services.resolved = {
      enable = true;
      dnssec = "true";
      domains = nameservers;
      dnsovertls = "true";
    };
  })
]
