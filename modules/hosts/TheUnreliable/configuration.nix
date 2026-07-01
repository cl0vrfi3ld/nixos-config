{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.TheUnreliable-configuration = { config, pkgs, ... }: {
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

    features.niri = {
      configPath = toString (
        pkgs.replaceVars ../../../dotfiles/niri/dms-config.kdl {
          user_path = "/home/coucoucl0vr/.config/niri";
        }
      );
    };

    # Override or define machine-specific settings
    time.timeZone = "America/New_York";
    # Leave this one be
    system.stateVersion = "25.05"; # Did you read the comment?

    # Home-Manager host-level settings
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "old";

    imports = [
      ../../../cachix.nix
    ];
  };
}
