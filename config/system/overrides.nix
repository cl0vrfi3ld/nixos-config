# Nixpkgs overrides
{
  pkgs,
  system,
  inputs,
  ...
}:

{
  nixpkgs.overlays = [
    (final: prev: {
      systemd = inputs.nixpkgs-systemd-compat.legacyPackages.${system}.systemd;
    })
  ];
}
