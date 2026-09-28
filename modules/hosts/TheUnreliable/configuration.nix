{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.TheUnreliable-configuration =
    {
      config,
      options,
      pkgs,
      ...
    }:
    {
      # Configure core feature settings
      features.core = {
        trustedUsers = [ "coucoucl0vr" ];
        unfreePackages = [
          "castlabs-electron"
          "antigravity"
          "mathematica"
        ];
      };

      # Configure users feature settings
      features.users = {
        users.coucoucl0vr = {
          description = "Clover";
          isDesktopUser = true;
          extraGroups = [
            "networkmanager"
            "wheel"
            "podman"
            "kvm"
            "adbusers"
            "greeter"
            "uinput"
            "dialout"
            "plugdev"
          ];
          shell = pkgs.fish;
          sessionVariables = {
            EDITOR = "micro";
            TERMINAL = "ghostty";
            SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
          };
        };
      };

      # Configure nh feature settings
      features.nh = {
        flake = "/home/coucoucl0vr/nixos-config";
      };

      # Right Alt is the Compose key. Note that this takes RAlt away from
      # applications entirely -- Wine games see the key as dead, not merely
      # unmodified -- so Star Citizen's RAlt binds need rebinding onto LAlt.
      features.niri.raltCompose = true;

      # Hermes Agent CLI and desktop application
      features.ai.hermes-agent = {
        enable = true;
        desktop.enable = true;
      };

      # Override or define machine-specific settings
      networking.hostName = "TheUnreliable";
      time.timeZone = "America/New_York";
      # Leave this one be
      system.stateVersion = "25.05"; # Did you read the comment?

      programs.fuse.userAllowOther = true;

      # Home-Manager host-level settings
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.backupFileExtension = "old";

      assertions =
        let
          hasDmsGreeter =
            (options.services.displayManager.dms-greeter.enable.isDefined or false)
            && config.services.displayManager.dms-greeter.enable;
          hasTuigreet =
            (options.services.displayManager.tuigreet.enable.isDefined or false)
            && config.services.displayManager.tuigreet.enable;
          hasLy =
            (options.services.displayManager.ly.enable.isDefined or false)
            && config.services.displayManager.ly.enable;
          numEnabled = builtins.length (
            builtins.filter (x: x) [
              hasDmsGreeter
              hasTuigreet
              hasLy
            ]
          );
        in
        [
          {
            assertion = (numEnabled > 0);
            message = "No greeter is enabled! You may have accidentally omitted a greeter config, which could prevent graphical login.";
          }
          {
            assertion = (numEnabled < 2);
            message = "Multiple greeter modules are enabled! This will cause conflicts!";
          }
        ];

      imports = [
        ../../../cachix.nix
      ];
    };
}
