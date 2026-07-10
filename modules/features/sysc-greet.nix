{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.sysc-greet =
    {
      config,
      pkgs,
      ...
    }:
    {
      services.sysc-greet = {
        enable = true;
        compositor = "niri";
        niriPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };
    };
}
