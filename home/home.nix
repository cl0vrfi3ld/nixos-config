{
  config,
  inputs,
  system,
  pkgs,
  ...
}:

{
  imports = [
    ./config/flatpak.nix
    ./config/pkgs.nix
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

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/coucoucl0vr/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "micro";
    EDITOR = "micro";
    SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
  };

  # User-scoped `~/.config/containers/registries`
  xdg.configFile."containers/registries.conf".text = ''
    [registries.search]
    registries = ['docker.io']
  '';

  programs = {
    # Let Home Manager manage fish
    fish.enable = true;
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
    # Let Home Manager manage git
    git.enable = true;
    git.settings = {
      user.name = "cl0vrfi3ld";
      user.email = "cl0vr@noreply.git.cl0vr.co";
      init.defaultBranch = "main";
    };
    # let Home Manager manage vscode
    vscode.enable = true;
    vscode = {
      package = pkgs.vscodium-fhs;
    };

  };
  # Let Home Manager manage user flatpaks
  services.flatpak.enable = true;
}
