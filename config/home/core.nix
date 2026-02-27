# User-level core session variables and environment config
{ ... }:

{
  home.sessionVariables = {
    EDITOR = "micro";
    TERMINAL = "ghostty";
    SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
  };
}
