{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.bitwarden =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        environment.systemPackages = [
          pkgs.bitwarden-desktop
        ];

        # the current version of `bitwarden-desktop` on the `nixos-unstable` uses
        # an EOL version of electron. this is a temporary override until an
        # updated package gets processed through hydra
        nixpkgs.config.permittedInsecurePackages = [
          "electron-39.8.10"
        ];
      };
    };
}
