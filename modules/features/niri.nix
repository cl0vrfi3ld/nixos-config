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
                # Always point niri to xwayland-satellite and use the efficient iGPU render node
                {
                  xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;
                  # Render node numbers are assigned by probe order and are not
                  # stable across boots; the by-path symlink is. A hardcoded
                  # renderD129 would silently select the *dGPU* if numbering flipped.
                  debug."render-drm-device" = "/dev/dri/by-path/pci-0000:c5:00.0-render";
                  # Let the panel drop to its minimum refresh on static content.
                  # `props` renders "eDP-2" as a node argument rather than a
                  # nested child node -- see wrapper-modules' lib/toKdl.nix.
                  output = _: {
                    props = [ "eDP-2" ];
                    content.variable-refresh-rate = _: { };
                  };
                }
                (lib.mkIf (args.shell == "noctalia") {
                  prefer-no-csd = _: { };
                  window-rule = {
                    geometry-corner-radius = 20;
                    clip-to-geometry = true;
                  };
                  layout = {
                    gaps = 8;
                  };
                  spawn-at-startup = [
                    (lib.getExe self'.packages.myNoctalia)
                  ];
                  input = {
                    touchpad.natural-scroll = _: { };
                    disable-power-key-handling = _: { };
                  };
                  # Lid-close is handled solely by logind
                  # (services.logind.settings.Login.HandleLidSwitch =
                  # "suspend-then-hibernate"); a niri-side lid-close.spawn here would
                  # race it with a plain suspend, defeating hibernation. Locking
                  # before sleep is instead handled by a systemd
                  # sleep.target-ordered unit (see battery.nix).
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
