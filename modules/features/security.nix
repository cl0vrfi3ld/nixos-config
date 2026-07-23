{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.security =
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
    };
}
