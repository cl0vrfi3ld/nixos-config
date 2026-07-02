{ self, inputs, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    {
      # Tell niri we're using noctalia
      features.niri.shell = "noctalia";
      warnings = lib.mkIf (builtins.length options.features.niri.shell.definitions > 1) [
        "Noctalia shell module is imported, but `features.niri.shell` is defined in multiple places. It may be overwriting or overwritten by another config!"
      ];

      imports = [
        self.nixosModules.noctalia-theming
        self.nixosModules.noctalia-dependencies
      ];
    };
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      # settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
