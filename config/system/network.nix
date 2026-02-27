# System-level network configuration (NetworkManager, iwd, VPNs, DNS)
{ config, pkgs, lib, ... }:
let
  networkCompatibilityMode = false;
  nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
    "8.8.8.8"
  ];
in
lib.mkMerge [
  {
    networking.hostName = "TheUnreliable";
    networking.networkmanager.enable = true;
    systemd.services.NetworkManager-wait-online.enable = false;
    networking.nftables.enable = true;
    networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

    # iwd configuration
    networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd.enable = true;
    iwd-provisioning.enable = true;
    iwd-provisioning.eduroam.enable = true;
    iwd-provisioning.eduroam = {
      domain = "uvm.edu";
      username = "mlevens";
      passwordPath = config.sops.secrets."iwd/eduroam/passwd".path;
    };
    networking.wireless.iwd.settings = {
      Network = { EnableIPv6 = true; };
      Settings = { AutoConnect = true; };
    };

    # Tailscale
    services.tailscale.enable = true;
    networking.interfaces.tailscale0.useDHCP = lib.mkDefault false;
    networking.firewall.checkReversePath = "loose";

    # Mullvad
    services.mullvad-vpn.enable = true;
    services.mullvad-vpn.package = pkgs.mullvad-vpn;

    # Proxychains
    programs.proxychains.enable = false;
    programs.proxychains.proxies = {
      tetherfi-ethernet-socks5 = { type = "socks5"; host = "172.26.115.147"; port = 8229; enable = true; };
      tetherfi-ethernet-http = { type = "http"; host = "172.26.115.147"; port = 8228; enable = true; };
    };
  }
  (lib.mkIf (!networkCompatibilityMode) {
    networking.nameservers = nameservers;
    services.resolved.enable = true;
    services.resolved.settings.Resolve = {
      DNSSEC = "true";
      Domains = nameservers;
      DNSOverTLS = "true";
    };
  })
]
