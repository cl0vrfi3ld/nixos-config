# System-level application and virtualization configuration
{
  config,
  pkgs,
  lib,
  ...
}:

{
  # AppImage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Fish shell
  programs.fish.enable = true;

  # KDE Connect
  programs.kdeconnect.enable = true;

  # Nix-LD
  programs.nix-ld.enable = true;

  # Virtualisation (Podman)
  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };
  environment.etc."containers/registries.conf".text = lib.mkDefault ''
    [registries.search]
    registries = ['docker.io']
  '';

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "dev.deedles.Trayscale"
  ];
  services.flatpak.overrides = {
    global = {
      Context.filesystems = [ "/nix/store:ro" ];
    };
  };

  # Waydroid
  # virtualisation.waydroid.enable = true;

  # Android Development
  # nixpkgs.config.android_sdk.accept_license = true;
  # programs.adb.enable = true;
  # services.udev.packages = [ pkgs.android-udev-rules ];

  # General Apps
  environment.systemPackages = [
    pkgs.bitwarden-desktop
  ];

  # AI Tools
  hardware.amdgpu.opencl.enable = true;
}
