{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.TheUnreliable-hardware = { config, pkgs, ... }: {
    # Include the results of the hardware scan from the root directory
    imports = [
      ../../../hardware-configuration.nix
    ];
  };
}
