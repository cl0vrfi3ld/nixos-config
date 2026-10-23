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
              enable = cfg.hermes-agent.enable;
              gateway.enable = cfg.hermes-agent.enable;
              # Override the package directly instead of setting extraPythonPackages: the module
              # re-overrides with its own extraDependencyGroups (default [ ]), which clobbers the
              # default package's optional integrations (messaging, anthropic, bedrock, ...)
              package = hermesBase.override { extraPythonPackages = [ memory-buckets ]; };
              # The unit PATH is sealed (hermes, bash, coreutils, git + extraPackages). The gateway's
              # kanban/cron dispatcher wraps workers in `systemd-run --user --scope` and refuses to
              # spawn when it can't find the binary. Use the host's systemd to match the running manager
              extraPackages = [ config.systemd.package ];
              backend.mode = "serve";
              backend.port = 9119;
              settings = {
                terminal.cwd = ".";
                approvals.mode = "smart";
                model = {
                  default = "z-ai/glm-5.3-flash";
                  provider = "openrouter";
                };
                # Lists replace on merge: this is the whole fallback chain, tried in order
                fallback_providers = [
                  { provider = "openrouter"; model = "z-ai/glm-5.3-flashx"; }
                  { provider = "openrouter"; model = "deepseek/deepseek-v4.1-flash"; }
                ];
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
                    prefetch_min_similarity = 0.30;
                  };
                };
                kanban.default_assignee = "developer";
                kanban.orchestrator_profile = "task-triage";
                # Lists replace on merge: this is the full CLI toolset list, not an addition
                platform_toolsets.cli = [
                  "a2a"
                  "browser"
                  "clarify"
                  "code_execution"
                  "computer_use"
                  "context_engine"
                  "cronjob"
                  "delegation"
                  "file"
                  "kanban"
                  "memory"
                  "session_search"
                  "skills"
                  "terminal"
                  "todo"
                  "tts"
                  "vision"
                  "web"
                ];
                skills.trusted_project_dirs = [
                  "/home/coucoucl0vr/nixos-config"
                ];
                tts = {
                  provider = "elevenlabs";
                  elevenlabs.voice_id = "L7kaJS9Njvqf8Zy4hmuk";
                };
              };
              environmentFiles = [ config.sops.secrets."hermes-agent".path ];

              # Anytype MCP server (stdio via npx; npx is on the unit PATH via the hermes wrapper).
              # The bearer token lives in the sops `hermes-agent` secret as ANYTYPE_API_KEY —
              # `''${...}` in an MCP env value is resolved from the profile's `.env` at runtime,
              # so no secret ends up in the world-readable store.
              mcpServers.anytype = {
                command = "${pkgs.bun}/bin/bunx";
                args = [
                  "-y"
                  "@anyproto/anytype-mcp"
                ];
                env.OPENAPI_MCP_HEADERS = ''{"Authorization":"Bearer ''${ANYTYPE_API_KEY}","Anytype-Version":"2025-11-08"}'';
              };
            };
          programs.hermes-agent = {
            enable = cfg.hermes-agent.enable;
            desktop.enable = cfg.hermes-agent.desktop.enable;
          };
        });
      };
    };
}
