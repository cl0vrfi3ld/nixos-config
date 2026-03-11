# Nixpkgs overrides
{ pkgs, ... }:

{
  nixpkgs.overlays = [
    # currently boost in dwarfs is broken, we pin it to the previous version
    # (final: prev: {
    #   # https://github.com/Bad3r/nixos/blob/main/modules/system76/custom-packages-overlay.nix#L26C9-L28C11
    #   dwarfs = prev.dwarfs.override {
    #     boost = prev.boost187;
    #   };
    # })
  ];
}
