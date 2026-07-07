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
          animation = "dur_file";
          battery_id = "BAT1";
          bigclock = "en";
          dur_file_path = "${../../resources/ly-anim-blackhole-smooth-240x67.dur}";
          service_name = "ly";
        };
      };
    };
}
