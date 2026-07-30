{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.user-apps =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        home-manager.users = self.lib.applyDesktopHome config (
          username:
          let
            selfprivacy-app = inputs.self-privacy.packages.${pkgs.stdenv.hostPlatform.system}.default;
            pano-scrobbler = inputs.pano-scrobbler.packages.${pkgs.stdenv.hostPlatform.system}.default;
          in
          {
            home.packages = with pkgs; [
              # Utils
              gearlever
              usbimager
              wl-clipboard
              selfprivacy-app
              btop-rocm
              # Chat
              fluffychat
              signal-desktop
              # Internet
              mullvad-browser
              nextcloud-client
              # Documents
              libreoffice
              # Notes/Organized Docs and Data
              obsidian
              anytype
              # Media
              mpv
              vlc
              # Game streaming
              moonlight-qt
              # Art/Design
              krita
              # Music
              picard
              chromaprint
              pano-scrobbler
              lrcget
              mixxx
              ardour
              # tidal-hifi
              sone
              finamp
            ];

            # Vesktop/Vencord
            programs.vesktop.enable = true;
            programs.vesktop = {
              settings = {
                arRPC = true;
                checkUpdates = false;
                disableMinSize = true;
                discordBranch = "stable";
                hardwareAcceleration = true;
              };
            };

            # Math Junk Desktop Entries
            xdg.desktopEntries = {
            };
          }
        );
      };
    };
}
