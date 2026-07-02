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
      });
    };
}
