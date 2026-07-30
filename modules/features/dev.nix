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
        home-manager.users = self.lib.applyDesktopHome config (
          username:
          let
            # intellij-idea-fhs = pkgs.buildFHSEnv {
            #   name = "idea";
            #   targetPkgs =
            #     pkgs:
            #     (with pkgs; [
            #       jetbrains.idea-oss
            #       jdk
            #     ]);
            #   runScript = "idea-oss";
            # };
          in
          {
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
              # android-studio
              antigravity-ide-fhs
              kdePackages.kate
              # intellij-idea-fhs
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

            # IntelliJ FHS Desktop Entry
            # xdg.desktopEntries = {
            #   intellij-idea-fhs = {
            #     name = "JetBrains IntelliJ IDEA";
            #     genericName = "Integrated Development Environment";
            #     comment = "JetBrains IntelliJ IDEA with FHS environment";
            #     exec = "intellij-idea-fhs %F";
            #     icon = "${pkgs.jetbrains.idea-oss}/share/icons/hicolor/scalable/apps/idea-oss.svg";
            #     terminal = false;
            #     categories = [
            #       "Development"
            #       "Science"
            #       "Education"
            #     ];
            #     mimeType = [
            #       "text/x-java-source"
            #       "application/java-vm"
            #     ];
            #   };
            # };
          }
        );
      };
    };
}
