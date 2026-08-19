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
          animation = "matrix";
          battery_id = "BAT1";
          bigclock = "en";
          service_name = "ly";
        };
      };
    };
}
