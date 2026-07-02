{ self, inputs, ... }: {
  flake.nixosModules.noctalia-theming =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    self.lib.mkDesktopHome config (username: {
      # Cursor theming
      home.pointerCursor = {
        gtk.enable = true;
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
      };
      home.packages = with pkgs; [
        # clipboard history
        cliphist
        wl-clip-persist
      ];
    });
}

