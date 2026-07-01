{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.core =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.features.core = {
        unfreePackages = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "List of unfree packages to allow.";
        };

        trustedUsers = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          description = "List of users to add to nix.settings.trusted-users.";
        };
      };

      config = {
        time.timeZone = lib.mkDefault "America/New_York";
        i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
        i18n.extraLocaleSettings = {
          LC_ADDRESS = lib.mkDefault "en_US.UTF-8";
          LC_IDENTIFICATION = lib.mkDefault "en_US.UTF-8";
          LC_MEASUREMENT = lib.mkDefault "en_US.UTF-8";
          LC_MONETARY = lib.mkDefault "en_US.UTF-8";
          LC_NAME = lib.mkDefault "en_US.UTF-8";
          LC_NUMERIC = lib.mkDefault "en_US.UTF-8";
          LC_PAPER = lib.mkDefault "en_US.UTF-8";
          LC_TELEPHONE = lib.mkDefault "en_US.UTF-8";
          LC_TIME = lib.mkDefault "en_US.UTF-8";
        };

        nix.settings = {
          trusted-users = [ "root" ] ++ config.features.core.trustedUsers;
          experimental-features = "nix-command flakes";
          sandbox = true;
          show-trace = true;
          auto-optimise-store = true;
          max-jobs = "auto";
          builders-use-substitutes = true;
        };

        nixpkgs.config.allowUnfree = true;
        nixpkgs.config.allowUnfreePredicate =
          pkg: builtins.elem (pkgs.lib.getName pkg) config.features.core.unfreePackages;

        services.accounts-daemon.enable = true;

        environment.systemPackages = with pkgs; [
          git
          gptfdisk
          micro
          unzip
          wget
        ];
      };
    };
}
