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
      config = {
        # KDE Connect (desktop device connectivity)
        programs.kdeconnect.enable = true;

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
