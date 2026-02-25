{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "cl0vrfi3ld";
      user.email = "cl0vr@noreply.git.cl0vr.co";
      init.defaultBranch = "main";
    };
  };
}
