{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.desktop-suite =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.features.desktop-suite = {
        # users = lib.mkOption {
        #   type = lib.types.listOf lib.types.str;
        #   default = self.lib.getDesktopUsers config;
        #   defaultText = lib.literalExpression "all desktop users configured in features.users.users";
        #   description = "Users to apply Home Manager packages and XDG portals to.";
        # };
      };

      config = {
        # System level packages (Apps and utility desktop components)
        environment.systemPackages = with pkgs; [
          kdePackages.partitionmanager
          ghostty
          easyeffects
          dgop

          # File managers
          kdePackages.dolphin
          yazi
        ];

        # Fonts
        fonts.packages = with pkgs; [
          nerd-fonts.fira-code
          nerd-fonts.roboto-mono
          roboto
          nerd-fonts.open-dyslexic
          noto-fonts-color-emoji
        ];

        # XDG menu specification
        environment.etc."xdg/menus/applications.menu".source = ../../dotfiles/xdg-config/applications.menu;

        # Home-Manager configuration per user
        home-manager.users = self.lib.applyDesktopHome config (username: {
          # Home Manager Packages (Apps)
          home.packages = with pkgs; [
            kdePackages.okular
            kdePackages.elisa
            kdePackages.gwenview
            kdePackages.ark
          ];

          # User-specific config files
          # xdg.configFile = {
          #   "dolphinrc".source = ../../dotfiles/dolphin/dolphinrc;
          # };

          # XDG Portal Configuration (User level)
          xdg.portal = {
            enable = true;
            xdgOpenUsePortal = true;
            extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
            configPackages = [ pkgs.xdg-desktop-portal-gtk ];
            config.common.default = "gtk";
          };
        });
      };
    };
}
