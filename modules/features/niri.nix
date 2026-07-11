{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    {
      options.features.niri = {
        configPath = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = ''
            Store path (as a string) to a config.kdl file.
            Use toString on derivations like pkgs.replaceVars to convert them.
          '';
        };
        shell = lib.mkOption {
          type = lib.types.enum [
            "dms"
            "noctalia"
          ];
          description = "The shell that is being used";
        };
      };

      config = {
        programs.niri = {
          enable = true;
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri.override {
            configPath = config.features.niri.configPath;
            shell = config.features.niri.shell;
          };
        };
        services.xserver.enable = false;
        environment.systemPackages = lib.mkIf (config.features.niri.shell == "dms") [
          pkgs.xwayland-satellite
        ];
      };
    };

  perSystem =
    {
      pkgs,
      system,
      self',
      ...
    }:
    {
      packages.myNiri =
        pkgs.lib.makeOverridable
          (
            args:
            let
              noctaliaBindsKdl = toString (
                pkgs.replaceVars ../../dotfiles/niri/noctalia-binds.kdl {
                  noctalia = lib.getExe self'.packages.myNoctalia;
                  ghostty = lib.getExe pkgs.ghostty;
                }
              );
            in
            inputs.wrapper-modules.wrappers.niri.wrap {
              inherit pkgs;

              # When a custom config path is provided, set it directly on
              # "config.kdl".path to bypass the wrapper's build-time KDL
              # generation and `niri validate` check. This is necessary
              # because the config may contain runtime `include` directives
              # pointing to files in the user's home directory (e.g. DMS
              # generated themes), which don't exist inside the Nix sandbox.
              "config.kdl".path = lib.mkIf (args.configPath != null) args.configPath;

              extraSettings = [
                {
                  include = lib.mkIf (args.shell == "noctalia") noctaliaBindsKdl;
                }
                {
                  include = lib.mkIf (args.shell == "noctalia") [
                    { optional = true; }
                    "~/.config/niri/noctalia.kdl"
                  ];
                }
              ];

              settings = lib.mkMerge [
                # Always point niri to xwayland-satellite
                {
                  xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
                }
                (lib.mkIf (args.shell == "noctalia") {
                  prefer-no-csd = _: { };
                  window-rule = {
                    geometry-corner-radius = 20;
                    clip-to-geometry = true;
                  };
                  layout = {
                    gaps = 8;
                    # focus-ring = {
                    #   width = 4.0;
                    # };
                  };
                  spawn-at-startup = [
                    (lib.getExe self'.packages.myNoctalia)
                  ];
                  input = {
                    touchpad.natural-scroll = _: { };
                    disable-power-key-handling = _: { };
                  };
                  switch-events = {
                    lid-close.spawn = [
                      "${lib.getExe self'.packages.myNoctalia}"
                      "ipc"
                      "call"
                      "sessionMenu"
                      "lockAndSuspend"
                    ];
                  };
                })
              ];
            }
          )
          {
            configPath = null;
            shell = null;
          };
    };
}
