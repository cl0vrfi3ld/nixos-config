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
      config = {
        features.core.unfreePackages = [
          "claude-code"
          "antigravity"
        ];

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
            # IDEs
            antigravity-ide-fhs
            kdePackages.kate
            # Zed's Vulkan backend enumerates every DRM render node at startup
            # and keeps an fd on the dGPU, holding 0000:03:00.0 and its two
            # PCIe bridges in D0 indefinitely (~2-4 W). MESA_VK_DEVICE_SELECT
            # filters after enumeration, so the node has to be invisible to
            # the process -- extend the FHS env's own bwrap invocation.
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
            # AI
            antigravity-cli
            claude-code
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
