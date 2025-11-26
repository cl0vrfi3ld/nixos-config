{ config, pkgs, ... }:
{
  # enable tailscale
  services.tailscale.enable = true;
  # disable dhcp on the tailscale interface
  networking.interfaces.tailscale0.useDHCP = pkgs.lib.mkDefault false;
  # fix DNS when using exit node
  networking.firewall.checkReversePath = "loose";
}
