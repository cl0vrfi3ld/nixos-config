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
      imports = [ self.nixosModules.tuigreet-service ];
      services.displayManager.tuigreet.enable = true;
    };
  flake.nixosModules.tuigreet-service =
    {
      config,
      options,
      pkgs,
      lib,
      ...
    }:
    {
      options.services.displayManager.tuigreet = {
        enable = lib.mkEnableOption "tuigreet display manager";
      };
      config =
        let
          cfg = config.services.displayManager.tuigreet;
        in
        lib.mkIf cfg.enable {
          services.greetd = {
            enable = true;
            settings = {
              default_session = {
                command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd niri";
                user = "greeter";
              };
            };
          };
        };
    };
}
