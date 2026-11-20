{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.syncthing =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.features.syncthing;
    in
    {
      options.features.syncthing = {
        tray.enable = lib.mkEnableOption "the Syncthing tray icon (syncthingtray)";

        openFirewall = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open Syncthing's default ports: 22000/tcp+udp for sync, 21027/udp for local discovery.";
        };

        settings = lib.mkOption {
          type = lib.types.attrsOf lib.types.anything;
          default = { };
          example = lib.literalExpression ''
            {
              devices.phone.id = "XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX-XXXXXXX";
              folders.notes = {
                path = "~/Notes";
                devices = [ "phone" ];
              };
            }
          '';
          description = "Passed through to Home Manager's services.syncthing.settings.";
        };
      };

      config = {
        # The HM module only runs the user service; it has no firewall knob
        networking.firewall = lib.mkIf cfg.openFirewall {
          allowedTCPPorts = [ 22000 ];
          allowedUDPPorts = [
            22000
            21027
          ];
        };

        home-manager.users = self.lib.applyDesktopHome config (username: {
          services.syncthing = {
            enable = true;
            tray.enable = cfg.tray.enable;
            inherit (cfg) settings;
            # HM defaults both overrides to true, which makes syncthing-init delete every
            # device/folder not declared here as soon as *any* setting is set. Only take
            # ownership of devices/folders when the host actually declares them, so pairing
            # through the web UI keeps working otherwise.
            overrideDevices = cfg.settings ? devices;
            overrideFolders = cfg.settings ? folders;
          };
        });
      };
    };
}
