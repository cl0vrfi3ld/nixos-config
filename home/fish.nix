# user-level fish shell config
{ config, pkgs, ... }:
let
  home-flake = "/home/coucoucl0vr/.config/home-manager";
  system-flake = "/home/coucoucl0vr/nixos-config";
in
{
  programs.fish = {
    enable = true;
    interactiveShellInit = "";
    shellAbbrs = {
      # "sup" -> apply changes for the whole system (including home config)
      # This just rebuilds. It does NOT pull new versions from the internet.
      sup = "nh os switch ${system-flake} && nh home switch ${home-flake}";
      # "sug" -> update flake inputs and apply for the whole system (including home config)
      sug = "nh os switch --update --commit-lock-file ${system-flake} && nh home switch --update --commit-lock-file ${home-flake}";
      # "sclean" -> deep clean the system
      sclean = "nh clean all --keep 1";

      # "nup" -> apply nixos flake config
      nup = "nh os switch ${system-flake}";
      # "nug" -> update nixos flake inputs and apply
      nug = "nh os switch --update --commit-lock-file ${system-flake}";
      # "noops"/"nback" -> rollback config
      noops = "run0 nixos-rebuild switch --rollback";
      nback = "run0 nixos-rebuild switch --rollback";

      # "hmup" -> apply home-manager config
      hmup = "nh home switch ${home-flake}";
      # "hmug" -> update home-manager inputs and apply
      hmug = "nh home switch --update --commit-lock-file ${home-flake}";

      # git forge stuff
      cgit = "fj --host git.cl0vr.co";

      # system info
      info = "fastfetch";
    };

    # shellAliases = {
    #   npx = "bunx";
    # };
  };
  programs.fastfetch = {
    enable = true;
  };
}
