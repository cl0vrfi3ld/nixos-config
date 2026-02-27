{ config, pkgs, ... }:
let
  system-flake = "/home/coucoucl0vr/nixos-config";
  sudo-command = "run0";

  sysbld-cmd = "nh os switch ${system-flake}";
  sysupg-cmd = "nh os switch --update --commit-lock-file ${system-flake}";
  sysrollback-cmd = "${sudo-command} nixos-rebuild switch --rollback";
in
{
  programs.fish = {
    enable = true;
    interactiveShellInit = "";
    shellAbbrs = {
      sup = sysbld-cmd;
      sug = sysupg-cmd;
      soops = sysrollback-cmd;
      sback = sysrollback-cmd;
      sclean = "nh clean all --keep 1";
      nup = sysbld-cmd;
      nug = sysupg-cmd;
      noops = sysrollback-cmd;
      nback = sysrollback-cmd;
      cgit = "fj --host git.cl0vr.co";
      info = "fastfetch";
    };
  };

  programs.fastfetch = {
    enable = true;
  };
}
