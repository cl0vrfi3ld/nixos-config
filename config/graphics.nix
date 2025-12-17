{
  config,
  pkgs,
  lib,
  ...
}:

{
  hardware.graphics.enable = true;
  hardware.graphics.extraPackages = with pkgs; [
    libva
    libva-vdpau-driver
  ];
  # hardware.amdgpu.initrd.enable = lib.mkDefault true;
}
