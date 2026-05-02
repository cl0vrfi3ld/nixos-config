# User-level application configuration and flatpaks
{
  config,
  pkgs,
  inputs,
  system,
  ...
}:

let
  selfprivacy-app = inputs.self-privacy.packages.${system}.release;
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
    vesktop
    fluffychat
    signal-desktop
    # Internet
    mullvad-browser
    librewolf
    nextcloud-client
    # Documents
    libreoffice
    onlyoffice-desktopeditors
    # Notes/Organized Docs and Data
    obsidian
    # Media
    mpv
    vlc
    # Art/Design
    krita
    # Music
    picard
    chromaprint
    lrcget
    mixxx
    ardour
    tidal-hifi
    feishin
    cavasik
    # AI
    gemini-cli
  ];

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
    "io.anytype.anytype"
    "com.github.zocker_160.SyncThingy"
    "com.toolstack.Folio"
    "re.sonny.Eloquent"
    "com.moonlight_stream.Moonlight"
    "com.unicornsonlsd.finamp"
    "org.vinegarhq.Sober"
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
