{ self, inputs, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    let
      desktopUsers = lib.mapAttrsToList (name: user: name) (
        lib.filterAttrs (name: user: user.isDesktopUser) config.features.users.users
      );
    in
    {
      # Tell niri we're using noctalia
      features.niri.shell = "noctalia";
      warnings = lib.mkIf (builtins.length options.features.niri.shell.definitions > 1) [
        "Noctalia shell module is imported, but `features.niri.shell` is defined in multiple places. It may be overwriting or overwritten by another config!"
      ];

      home-manager.users = lib.genAttrs desktopUsers (username: {
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
    };
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      # settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
