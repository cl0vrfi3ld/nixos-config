# User-level command-line and fish shell configuration
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
      # "sup" -> apply changes for the whole system (including home config)
      sup = sysbld-cmd;
      # "sug" -> update flake inputs and apply for the whole system (including home config)
      sug = sysupg-cmd;
      # "soops"/"sback" -> rollback system config
      soops = sysrollback-cmd;
      sback = sysrollback-cmd;
      # "sbld" -> build the system config (but don't switch!)
      sbld = "cd ${system-flake} && nh os build .";
      # "sclean" -> deep clean the system
      sclean = "nh clean all --keep 1";

      # "nup" -> alias for "sup"
      nup = sysbld-cmd;
      # "nug" -> alias for "sug"
      nug = sysupg-cmd;
      # "noops"/"nback" -> alias for "soops"/"sback"
      noops = sysrollback-cmd;
      nback = sysrollback-cmd;

      # git forge stuff
      cgit = "fj --host git.cl0vr.co";

      # system info
      info = "fastfetch";

      # nix run shortcut
      nixr = "nix run nixpkgs#";

      # reboot to systemd-boot boot menu
      reboot-to-menu = "systemctl reboot --boot-loader-menu=0";
    };
  };

  programs.fastfetch = {
    enable = true;
  };
}
