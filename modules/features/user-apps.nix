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

        home-manager.sharedModules = [ inputs.hermes-agent.homeManagerModules.default ];

        home-manager.users = self.lib.applyDesktopHome config (
          username:
          let
            selfprivacy-app = inputs.self-privacy.packages.${pkgs.stdenv.hostPlatform.system}.default;
            pano-scrobbler = inputs.pano-scrobbler.packages.${pkgs.stdenv.hostPlatform.system}.default;
            openwork = self.packages.${pkgs.stdenv.hostPlatform.system}.openwork;
            # hermes-agent = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.default;
            # hermes-agent-desktop = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.desktop;
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
              # finamp
              # AI
              openwork
              # other
              betaflight-configurator
            ];

            # Hermes Agent
            services.hermes-agent = {
              enable = true;
              backend.mode = "serve";
              backend.port = 9119;
              environmentFiles = [ config.sops.secrets."hermes-agent".path ];
            };
            programs.hermes-agent = {
              enable = true;
              desktop.enable = true;
            };

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
