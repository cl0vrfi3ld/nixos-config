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
        features.core.unfreePackages = [
          "obsidian"
        ];

        home-manager.users = self.lib.applyDesktopHome config (
          username:
          let
            selfprivacy-app = inputs.self-privacy.packages.${pkgs.stdenv.hostPlatform.system}.default;
            pano-scrobbler = inputs.pano-scrobbler.packages.${pkgs.stdenv.hostPlatform.system}.default;
            claude-desktop = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.claude-desktop;
          in
          {
            home.packages = with pkgs; [
              # Utils
              # gearlever
              # usbimager
              wl-clipboard
              selfprivacy-app
              btop-rocm
              # Chat
              fluffychat
              # signal-desktop
              # Internet
              mullvad-browser
              chromium
              nextcloud-client
              # Documents
              libreoffice
              # Notes/Organized Docs and Data
              obsidian
              anytype
              # Media
              mpv
              vlc
              # obs-studio
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
              # ardour
              # tidal-hifi
              sone
              # finamp
              # AI
              claude-desktop
              # other
              betaflight-configurator
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

            # Desktop Entries
            xdg.desktopEntries = {
            };
          }
        );
      };
    };
}
