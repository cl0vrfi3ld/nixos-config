# System-level network configuration (NetworkManager, iwd, VPNs, DNS)
{
  config,
  pkgs,
  lib,
  ...
}:
{
  networking.hostName = "TheUnreliable";
  networking.networkmanager.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;
  networking.nftables.enable = true;

  # Do NOT set networking.interfaces.wlan0.useDHCP: NetworkManager already does
  # DHCP on wlan0. Setting it spawns a second, competing dhcpcd client (via
  # `allowinterfaces wlan0`), producing duplicate/stale leases that black-hole
  # the interface (a dead lease can win the route metric and drop all traffic).

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
    Network = {
      EnableIPv6 = true;
    };
    Settings = {
      AutoConnect = true;
    };
  };

  # DNS is left to NetworkManager/DHCP. Note: Tailscale MagicDNS pins
  # /etc/resolv.conf to 100.100.100.100 on every network, which breaks
  # captive-portal wifi (workaround: `tailscale down`, log in, `tailscale up`).
  # Proper fix (TODO): enable services.resolved WITHOUT DNSSEC/DoT and set
  # networking.networkmanager.dns = "systemd-resolved" for split DNS, so only
  # *.discus-theropod.ts.net resolves via MagicDNS and the rest uses the
  # network's own resolver.

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
    tetherfi-ethernet-socks5 = {
      type = "socks5";
      host = "172.26.115.147";
      port = 8229;
      enable = true;
    };
    tetherfi-ethernet-http = {
      type = "http";
      host = "172.26.115.147";
      port = 8228;
      enable = true;
    };
  };
}
