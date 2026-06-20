# User-level application configuration and flatpaks
{
  pkgs,
  inputs,
  system,
  ...
}:

let
  selfprivacy-app = inputs.self-privacy.packages.${system}.default;
  pano-scrobbler = inputs.pano-scrobbler.packages.${system}.default;
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
    tidal-hifi
    sone
    finamp
    # AI
    gemini-cli
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

  # Zen Browser
  programs.zen-browser.enable = true;
  programs.zen-browser.policies = {
    AutofillAddressEnabled = false;
    AutofillCreditCardEnabled = false;
    DisableAppUpdate = true;
    DisableFeedbackCommands = true;
    DisableFirefoxStudies = true;
    DisablePocket = true;
    DisableTelemetry = true;
    DontCheckDefaultBrowser = true;
    NoDefaultBookmarks = true;
    OfferToSaveLogins = false;
    EnableTrackingProtection = {
      Value = true;
      Locked = false;
      Cryptomining = true;
      Fingerprinting = true;
    };
  };

  # Math Junk Desktop Entries
  xdg.desktopEntries = {
  };

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.gnome.World.PikaBackup"
    "com.github.zocker_160.SyncThingy"
  ];
  services.flatpak.overrides = {
    global = {
      # Force Wayland by default
      Context.sockets = [
        "wayland"
        "!x11"
        "!fallback-x11"
      ];
      # allow access to the nix store
      Context.filesystems = [ "/nix/store:ro" ];
    };
    "org.gnome.World.PikaBackup" = {
      Environment = {
        SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
      };
      Context = {
        sockets = [ "ssh-agent" ];
        filesystems = [ "/home/coucoucl0vr/.bitwarden-ssh-agent.sock" ];
      };
    };
  };
}
