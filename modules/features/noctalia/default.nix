{ self, inputs, ... }:
{
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
      ];

      # Puts the wrapped `noctalia` on PATH (for `noctalia msg ...` by hand) and
      # enables the freedesktop sound theme it expects at runtime.
      programs.noctalia = {
        enable = true;
        package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNoctalia;
      };
    };

  perSystem =
    { pkgs, ... }:
    {
      # Noctalia v5. The wrapper points NOCTALIA_CONFIG_HOME at a generated
      # store directory, so ~/.config/noctalia (v4 leftovers included) is not
      # read; GUI changes still persist in ~/.local/state/noctalia/settings.toml.
      packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia.wrap {
        inherit pkgs;
        settings = import ./_settings.nix;
      };
    };
}
