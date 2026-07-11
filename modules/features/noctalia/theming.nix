{ self, inputs, ... }: {
  flake.nixosModules.noctalia-theming =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    {
      home-manager.users = self.lib.applyDesktopHome config (username: {
        # Cursor theming
        home.pointerCursor = {
          gtk.enable = true;
          package = pkgs.adwaita-icon-theme;
          name = "Adwaita";
          size = 24;
        };

        # GTK theming to remove top bars and set adw-gtk3 for Noctalia
        gtk = {
          enable = true;
          theme = {
            name = "adw-gtk3-dark"; # Typically dark is used with Noctalia, or adw-gtk3
            package = pkgs.adw-gtk3;
          };
          gtk3.extraConfig = {
            gtk-decoration-layout = ":";
          };
          gtk4 = {
            # theme = config.gtk.theme;
            theme = null;
            extraConfig = {
              gtk-decoration-layout = ":";
            };
          };
        };

        home.sessionVariables = {
          QT_QPA_PLATFORMTHEME = "qt6ct";
          QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
        };

        home.packages = with pkgs; [
          nwg-look
          qt6Packages.qt6ct
        ];
      });
    };
}
