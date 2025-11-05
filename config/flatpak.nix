# system-level flatpak config
{ config, pkgs, ... }:

{
    # flatpak packages to be installed/managed via nix
    services.flatpak.packages = [
      "io.github.kolunmi.Bazaar"
      # "com.bitwarden.desktop" # handled by native nixos pkg for better compatibility
      "app.zen_browser.zen"
      "app.devsuite.Ptyxis"
      "dev.deedles.Trayscale"
      # "it.mijorus.gearlever" # handled by native nixos pkg for better compatibility
    ];
}
