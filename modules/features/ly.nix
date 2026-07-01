{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.tuigreet =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      services.displayManager.ly = {
        enable = true;
        x11Support = false;
        settings = {
          save = true;
        };
      };
    };
}
