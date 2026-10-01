{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.ai =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.ai;

      # cua-driver shells out to these at runtime; upstream's package doesn't reference them
      cuaDriverBase = inputs.cua.packages.${pkgs.stdenv.hostPlatform.system}.cua-driver;
      cuaDriver = pkgs.symlinkJoin {
        name = "cua-driver-compat-wrapped-${cuaDriverBase.version}";
        paths = [ cuaDriverBase ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cua-driver --suffix PATH : ${
            lib.makeBinPath [
              (lib.getBin pkgs.glib) # gdbus: doctor's AT-SPI probe, GNOME/KWin helpers
              pkgs.wtype # Wayland virtual-keyboard typing
              pkgs.grim # wlroots screenshot fallback
              pkgs.wf-recorder # Wayland screen recording
              pkgs.ffmpeg-headless # recording encode
            ]
          }
        '';
        inherit (cuaDriverBase) meta;
      };
    in
    {
      options.features.ai = {
        hermes-agent = {
          enable = lib.mkEnableOption "the Hermes Agent CLI (programs.hermes-agent)";
          desktop.enable = lib.mkEnableOption "the Hermes Agent desktop application";
        };
        cua-driver.enable = lib.mkEnableOption "the CUA Driver computer-use MCP server";
      };

      imports = [ inputs.cua.nixosModules.cua-driver ];

      config = {
        # CUA Driver
        services.cua-driver = {
          enable = cfg.cua-driver.enable;
          package = cuaDriver;
        };
        # Opt into the experimental native Wayland backend (capture, AT-SPI)
        environment.sessionVariables = lib.mkIf cfg.cua-driver.enable {
          CUA_DRIVER_RS_ENABLE_WAYLAND = "1";
          HERMES_CUA_DRIVER_CMD = "${cuaDriver}/bin/cua-driver";
        };
        # Register the AT-SPI accessibility bus with D-Bus; upstream only installs the package
        services.gnome.at-spi2-core.enable = lib.mkIf cfg.cua-driver.enable true;

        home-manager.sharedModules = [ inputs.hermes-agent.homeManagerModules.default ];

        home-manager.users = self.lib.applyDesktopHome config (username: {
          # Hermes Agent
          services.hermes-agent =
            let
              hermesBase = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
              memory-buckets = hermesBase.python.pkgs.callPackage "${inputs.memory-buckets}/nix/package.nix" { };
            in
            {
              enable = true;
              # Override the package directly instead of setting extraPythonPackages: the module
              # re-overrides with its own extraDependencyGroups (default [ ]), which clobbers the
              # default package's optional integrations (messaging, anthropic, bedrock, ...)
              package = hermesBase.override { extraPythonPackages = [ memory-buckets ]; };
              backend.mode = "serve";
              backend.port = 9119;
              settings = {
                terminal.cwd = ".";
                display = {
                  interface = "tui";
                  show_reasoning = true;
                };
                memory = {
                  provider = "memory-buckets";
                  memory_enabled = false;
                  user_profile_enabled = false;
                };
                plugins = {
                  memory-buckets = {
                    prefetch_min_similarity = 0.35;
                  };
                };
                skills.trusted_project_dirs = [
                  "/home/coucoucl0vr/nixos-config"
                ];
                tts = {
                  provider = "elevenlabs";
                  elevenlabs.voice_id = "L7kaJS9Njvqf8Zy4hmuk";
                };
              };
              environmentFiles = [ config.sops.secrets."hermes-agent".path ];
            };
          programs.hermes-agent = {
            enable = cfg.hermes-agent.enable;
            desktop.enable = cfg.hermes-agent.desktop.enable;
          };
        });
      };
    };
}
