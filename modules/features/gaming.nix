{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.gaming =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.gaming;
    in
    {
      options.features.gaming = {
        extraCompatPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [ pkgs.proton-ge-bin ];
          description = "Extra Steam compatibility tools, also injected into Heroic's Proton packages.";
        };

        vr.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable VR support via ALVR.";
        };

        streaming.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable game streaming via Sunshine (with moondeck-buddy firewall rules).";
        };

        starCitizen.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable the Star Citizen (rsi-launcher) module.";
        };
      };

      config = {
        # Steam Configuration
        programs.steam = {
          enable = true;
          remotePlay.openFirewall = true;
          platformOptimizations.enable = true;
          extraCompatPackages = cfg.extraCompatPackages;
        };
        hardware.steam-hardware.enable = true;
        programs.gamescope.enable = true;
        programs.gamemode.enable = true;

        # Gaming Packages
        environment.systemPackages = [ pkgs.lact ];

        # VR Configuration
        programs.alvr = lib.mkIf cfg.vr.enable {
          enable = true;
          openFirewall = true;
        };

        # Sunshine config
        services.sunshine = lib.mkIf cfg.streaming.enable {
          enable = true;
          capSysAdmin = true;
          openFirewall = true;
          autoStart = false;
        };

        # Rules for moondeck-buddy
        networking.firewall = lib.mkIf cfg.streaming.enable {
          allowedTCPPorts = [ 59999 ];
          allowedUDPPorts = [ 59999 ];
        };

        # Star Citizen config
        programs.rsi-launcher = lib.mkIf cfg.starCitizen.enable {
          # Enables the star citizen module
          enable = true;
          location = "/too/Games/rsi-launcher";
          gamescope = {
            enable = false;
            args = [
              "-W 2560"
              "-H 1600"
            ];
          };
          # umu.enable = true;
          # wine = inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.lug-wine-bin;
          package =
            inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher.override
              (prev: {
                hidetray = true;
              });
        };

        # Home-Manager configuration per user
        home-manager.users = self.lib.applyDesktopHome config (username: {
          home.packages = [
            pkgs.prismlauncher
            (pkgs.heroic.override {
              extraPkgs = pkgs: [ pkgs.gamescope ] ++ cfg.extraCompatPackages;
            })
          ];
        });
      };
    };
}
