{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.gpu =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        # AI Tools
        hardware.amdgpu.opencl.enable = true;
      };
    };
}
