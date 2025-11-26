{ config, pkgs, ... }:
{
    # enable tailscale
  services.tailscale.enable = true;
}