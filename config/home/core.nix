# Core user-level session config
{ pkgs, ... }:

{
  home.sessionVariables = {
    EDITOR = "micro";
    TERMINAL = "ghostty";
    SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
  };

  # TODO: find a better place for this
  # GPG Config
  # programs.gpg = {
  #   enable = true;
  # };
}
