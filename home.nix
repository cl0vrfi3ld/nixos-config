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
    ./config/home/env.nix
    ./config/home/theme.nix
    ./config/home/niri.nix
    ./config/home/flatpak.nix
    ./config/home/nixpkgs.nix
    ./config/home/fish.nix
    ./config/home/git.nix
    ./config/home/vscode.nix
    ./config/home/containers.nix
    ./config/home/gaming.nix
    ./config/home/music.nix
    ./config/home/media.nix
    ./config/home/chat.nix
    ./config/home/email.nix
    ./config/home/internet.nix
    ./config/home/dev.nix
    ./config/home/ai.nix
    ./config/home/utils.nix
    ./config/home/math-junk.nix
    ./config/home/ssh.nix
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
