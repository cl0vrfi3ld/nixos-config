{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.fish =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        # Fish shell
        programs.fish.enable = true;

        # Home-Manager configuration per user
        home-manager.users = self.lib.applyDesktopHome config (
          username:
          let
            system-flake = config.features.nh.flake;
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
                # System switch & upgrade
                sup = sysbld-cmd;
                nup = sysbld-cmd;
                sug = sysupg-cmd;
                nug = sysupg-cmd;

                # Rollback
                soops = sysrollback-cmd;
                sback = sysrollback-cmd;
                noops = sysrollback-cmd;
                nback = sysrollback-cmd;

                # Build test & cleanup
                sbld = "cd ${system-flake} && nh os build .";
                sclean = "nh clean all --keep 1";

                # Tools & utilities
                cgit = "fj --host git.cl0vr.co";
                info = "fastfetch";
                nixr = "nix run nixpkgs#";
                reboot-to-menu = "systemctl reboot --boot-loader-menu=0";
              };
            };

            programs.fastfetch = {
              enable = true;
            };
          }
        );
      };
    };
}
