{ config, pkgs, ... }:

{
  services.mullvad-vpn.enable = true;
  # disable as i'm currently not using it and it has security impacts
  services.mullvad-vpn.enableExcludeWrapper = false;
}
