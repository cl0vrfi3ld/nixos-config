{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.boot =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.boot;
    in
    {
      imports = [
        inputs.lanzaboote.nixosModules.lanzaboote
      ];

      options.features.boot = {
        secureBoot.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Secure Boot via Lanzaboote (replaces systemd-boot).";
        };
        plymouth = {
          enable = lib.mkOption {
            type = lib.types.bool;
            default = true;
            description = "Enable the Plymouth boot splash and quiet boot.";
          };
          theme = lib.mkOption {
            type = lib.types.str;
            default = "deus_ex";
            description = "Plymouth theme to use.";
          };
        };
      };

      config = {
        # Bootloader / Secure Boot
        boot.loader.efi.canTouchEfiVariables = true;
        boot.loader.timeout = 0;

        # Secure Boot using Lanzaboote (takes over from systemd-boot)
        boot.loader.systemd-boot.enable = lib.mkIf cfg.secureBoot.enable (lib.mkForce false);
        boot.lanzaboote = lib.mkIf cfg.secureBoot.enable {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
        environment.systemPackages = lib.mkIf cfg.secureBoot.enable [ pkgs.sbctl ];

        # Kernel / initrd
        boot.kernelPackages = pkgs.linuxPackages_latest;
        boot.initrd.enable = true;
        boot.initrd.systemd.enable = true;

        # Plymouth splash + quiet boot
        boot.plymouth = lib.mkIf cfg.plymouth.enable {
          enable = true;
          theme = cfg.plymouth.theme;
          themePackages = with pkgs; [
            (adi1090x-plymouth-themes.override {
              selected_themes = [
                "rings"
                "deus_ex"
              ];
            })
          ];
        };
        boot.consoleLogLevel = lib.mkIf cfg.plymouth.enable 3;
        boot.initrd.verbose = lib.mkIf cfg.plymouth.enable false;
        boot.kernelParams = lib.mkIf cfg.plymouth.enable [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "udev.log_priority=3"
          "rd.systemd.show_status=auto"
        ];
      };
    };
}
