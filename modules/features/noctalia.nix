{ self, inputs, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      # Tell niri we're using noctalia
      config.features.niri.shell = "noctalia";
    };
  perSystem = { pkgs, ... }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
      # settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
    };
  };
}
