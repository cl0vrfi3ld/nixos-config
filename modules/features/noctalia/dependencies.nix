{ self, inputs, ... }: {
  flake.nixosModules.noctalia-dependencies =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    {
      home-manager.users = self.lib.applyDesktopHome config (username: {
        home.packages = with pkgs; [
          # clipboard history
          cliphist
          wl-clip-persist
        ];
      });
    };
}
