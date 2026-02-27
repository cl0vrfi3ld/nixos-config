{
  config,
  inputs,
  system,
  pkgs,
  lib,
  ...
}:

{
  imports = [
    # --- home manager modules ---
    # declarative flatpak management
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
    # zen browser module
    inputs.zen-browser.homeModules.twilight
    # --- home config ---
    ./config/home/core.nix
    ./config/home/desktop.nix
    ./config/home/apps.nix
    ./config/home/dev.nix
    ./config/home/cli.nix
    ./config/home/gaming.nix
  ];
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "coucoucl0vr";
  home.homeDirectory = "/home/coucoucl0vr";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.05"; # Please read the comment before changing.

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
