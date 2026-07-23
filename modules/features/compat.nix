{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.compat =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        # AppImage support
        programs.appimage.enable = true;
        programs.appimage.binfmt = true;

        # Nix-LD
        programs.nix-ld.enable = true;
      };
    };
}
