{ self, inputs, lib, ... }: {
  flake.nixosModules.nh = { config, pkgs, lib, ... }: {
    options.features.nh = {
      flake = lib.mkOption {
        type = lib.types.str;
        default = "/home/coucoucl0vr/nixos-config";
        description = "Path to the NixOS configuration flake directory.";
      };
    };

    config = {
      environment.sessionVariables = {
        NH_FLAKE = config.features.nh.flake;
        NH_ELEVATION_PROGRAM = "${pkgs.systemdUkify}/bin/run0";
      };
      programs.nh = {
        enable = true;
        clean.enable = true;
        clean.extraArgs = "--keep 3";
      };
    };
  };
}
