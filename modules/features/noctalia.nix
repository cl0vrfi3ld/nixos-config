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
      config.features.niri.shell = "noctalia";
      config.warnings = lib.mkIf (builtins.length options.features.niri.shell.definitions > 1) [
        "Noctalia shell module is imported, but `features.niri.shell` is defined in multiple places. It may be overwriting or overwritten by another config!"
      ];

    };
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      # settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
