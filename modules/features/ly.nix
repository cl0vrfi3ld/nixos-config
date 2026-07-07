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
      # environment.systemPackages = [ pkgs.durdraw ];
      services.displayManager.ly = {
        enable = true;
        x11Support = false;
        settings = {
          save = true;
          battery_id = "BAT1";
          bigclock = "en";
          service_name = "ly";
        };
      };
    };
}
