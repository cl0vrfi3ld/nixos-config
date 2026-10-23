{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.dev =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config =
        let
          intellij-idea-fhs = pkgs.buildFHSEnv {
            name = "idea";
            targetPkgs =
              pkgs:
              (with pkgs; [
                jetbrains.idea-oss
                jdk
              ]);
            runScript = "idea-oss";
          };
          agy = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.antigravity-cli;
          claude = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-code;
        in
        {
          features.core.unfreePackages = [
            "claude-code"
            "antigravity"
          ];

          nixpkgs.config.android_sdk.accept_license = true;

          home-manager.users = self.lib.applyDesktopHome config (username: {
            home.packages = with pkgs; [
              # Tools
              android-tools
              cachix
              direnv
              distrobox
              nixd
              nixfmt
              forgejo-cli
              gh
              # IDEs
              kdePackages.kate
              android-studio
              # Custom wrapper around zed to hide the dGPU from it
              (zed-editor-fhs.overrideAttrs (old: {
                # Render node numbering follows probe order and is not stable
                # across boots, so resolve the iGPU via its by-path symlink.
                extraPreBwrapCmds = (old.extraPreBwrapCmds or "") + ''
                  igpu_card=$(${lib.getExe' pkgs.coreutils "readlink"} -f /dev/dri/by-path/pci-0000:c5:00.0-card)
                  igpu_render=$(${lib.getExe' pkgs.coreutils "readlink"} -f /dev/dri/by-path/pci-0000:c5:00.0-render)
                '';
                extraBwrapArgs = old.extraBwrapArgs ++ [
                  "--tmpfs /dev/dri"
                  ''--dev-bind "$igpu_card" "$igpu_card"''
                  ''--dev-bind "$igpu_render" "$igpu_render"''
                ];
              }))
              # Languages
              python3
              bun
              # AI
              agy
              claude
            ];

            programs.git = {
              enable = true;
              settings = {
                user.name = "cl0vrfi3ld";
                user.email = "cl0vr@noreply.git.cl0vr.co";
                init.defaultBranch = "main";
              };
            };

            programs.vscodium = {
              enable = true;
              package = pkgs.vscodium-fhs;
            };
          });
        };
    };
}
