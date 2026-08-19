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

        home-manager.users = self.lib.applyDesktopHome config (
          username: {
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
              zed-editor-fhs
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
          }
        );
      };
    };
}
