{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.ly =
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
