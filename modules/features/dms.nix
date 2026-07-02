{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.dms =
    {
      config,
      pkgs,
      lib,
      options,
      ...
    }:
    {
      options.features.dms = {
        user = lib.mkOption {
          type = lib.types.str;
          default = "coucoucl0vr";
          description = "The primary user to fetch DMS configurations for.";
        };
        # users = lib.mkOption {
        #   type = lib.types.listOf lib.types.str;
        #   default = lib.mapAttrsToList (name: user: name) (
        #     lib.filterAttrs (name: user: user.isDesktopUser) config.features.users.users
        #   );
        #   defaultText = lib.literalExpression "all desktop users configured in features.users.users";
        #   description = "Users to apply DMS specific home-manager settings and theming to.";
        # };
      };

      config = {
        # Tell niri we're using DMS
        features.niri.shell = "dms";
        warnings = lib.mkIf (builtins.length options.features.niri.shell.definitions > 1) [
          "DMS shell module is imported, but `features.niri.shell` is defined in multiple places. It may be overwriting or overwritten by another config!"
        ];
        # Display Manager / Greeter
        services.displayManager.dms-greeter = {
          enable = true;
          compositor.name = "niri";
          configHome = "/home/${config.features.dms.user}";
          quickshell.package = inputs.quickshell.packages.${pkgs.system}.default;
        };

        # DMS Shell
        programs.dank-material-shell = {
          enable = true;
          quickshell.package = inputs.quickshell.packages.${pkgs.system}.default;
          dgop.package = pkgs.dgop;
          systemd = {
            enable = true;
            restartIfChanged = true;
          };

          enableSystemMonitoring = true;
          enableVPN = true;
          enableDynamicTheming = true;
          enableAudioWavelength = true;
          enableCalendarEvents = true;
          enableClipboardPaste = true;

          plugins = {
            dankBatteryAlerts.enable = true;
            dankKDEConnect.enable = true;
            easyEffects.enable = true;
            niriScreenshot.enable = true;
            commandRunner.enable = true;
            webSearch.enable = true;
          };
        };

        programs.dsearch.enable = true;

        # System-level theming tools for DMS
        environment.systemPackages = with pkgs; [
          qt6Packages.qt5compat
          qt6Packages.qt6ct
        ];

        # Home-Manager specific theming config for DMS
        home-manager.users = self.lib.applyDesktopHome config (username: {
          # Cursor theming
          home.pointerCursor = {
            gtk.enable = true;
            package = pkgs.adwaita-icon-theme;
            name = "Adwaita";
            size = 24;
          };

          # GTK Icon theming
          gtk.iconTheme = {
            package = pkgs.papirus-icon-theme;
            name = "Papirus";
          };

          # QT platform themes
          home.sessionVariables = {
            QT_QPA_PLATFORMTHEME = "qt6ct";
            QT_QPA_PLATFORMTHEME_QT6 = "qt6ct";
          };

          # Theme packages
          home.packages = with pkgs; [
            papirus-icon-theme
            adwaita-icon-theme
            kdePackages.breeze-icons
          ];
        });
      };
    };
}
