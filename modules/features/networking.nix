{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.networking =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.networking;
    in
    {
      imports = [
        inputs.nix-iwd-provisioning.nixosModules.nix-iwd-provisioning
      ];

      options.features.networking = {
        eduroam = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Provision eduroam via nix-iwd-provisioning.";
          };
          domain = lib.mkOption {
            type = lib.types.str;
            default = "uvm.edu";
            description = "eduroam realm/domain.";
          };
          username = lib.mkOption {
            type = lib.types.str;
            default = "mlevens";
            description = "eduroam username.";
          };
          passwordPath = lib.mkOption {
            type = lib.types.str;
            default = config.sops.secrets."iwd/eduroam/passwd".path;
            defaultText = lib.literalExpression ''config.sops.secrets."iwd/eduroam/passwd".path'';
            description = "Path to the file holding the eduroam password.";
          };
        };
        tailscale.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Tailscale.";
        };
        mullvad.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the Mullvad VPN daemon.";
        };
        proxychains.enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Enable proxychains with the tetherfi proxies.";
        };
      };

      config = {
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
        networking.wireless.iwd.settings = {
          Network = {
            EnableIPv6 = true;
          };
          Settings = {
            AutoConnect = true;
          };
        };

        # eduroam provisioning
        iwd-provisioning.enable = lib.mkIf cfg.eduroam.enable true;
        iwd-provisioning.eduroam = lib.mkIf cfg.eduroam.enable {
          enable = true;
          domain = cfg.eduroam.domain;
          username = cfg.eduroam.username;
          passwordPath = cfg.eduroam.passwordPath;
        };

        # DNS is left to NetworkManager/DHCP. Note: Tailscale MagicDNS pins
        # /etc/resolv.conf to 100.100.100.100 on every network, which breaks
        # captive-portal wifi (workaround: `tailscale down`, log in, `tailscale up`).
        # Proper fix (TODO): enable services.resolved WITHOUT DNSSEC/DoT and set
        # networking.networkmanager.dns = "systemd-resolved" for split DNS, so only
        # *.discus-theropod.ts.net resolves via MagicDNS and the rest uses the
        # network's own resolver.

        # Tailscale
        services.tailscale.enable = lib.mkIf cfg.tailscale.enable true;
        networking.interfaces.tailscale0.useDHCP = lib.mkIf cfg.tailscale.enable (lib.mkDefault false);
        networking.firewall.checkReversePath = lib.mkIf cfg.tailscale.enable "loose";

        # Mullvad
        services.mullvad-vpn.enable = lib.mkIf cfg.mullvad.enable true;
        services.mullvad-vpn.gui.enable = lib.mkIf cfg.mullvad.enable true;

        # Proxychains
        programs.proxychains.enable = cfg.proxychains.enable;
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
      };
    };
}
