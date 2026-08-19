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
      imports = [
        inputs.sysc-greet.nixosModules.default
      ];

      services.sysc-greet = {
        enable = true;
        compositor = "niri";
        niriPackage = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
      };
    };
}
