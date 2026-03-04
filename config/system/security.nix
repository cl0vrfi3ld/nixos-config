# System-level security and polkit configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Enable polkit
  security.polkit.enable = true;
  # Enable gnome-keyring
  services.gnome.gnome-keyring.enable = true;
  # Enable fprintd
  services.fprintd.enable = true;
  # TOD didn't fix the issue
  # services.fprintd.tod = {
  #   enable = true;
  #   driver = pkgs.libfprint-2-tod1-goodix;
  # };
}
