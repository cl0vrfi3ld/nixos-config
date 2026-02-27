# User-level application configuration and flatpaks
{ config, pkgs, inputs, system, ... }:

let
  selfprivacy-app = inputs.self-privacy.packages.${system}.release;
  rstudio-fhs = pkgs.buildFHSEnv {
    name = "rstudio-fhs";

    # These packages will be available inside the FHS bubble
    targetPkgs = pkgs: (with pkgs; [
      # --- Core ---
      R rstudio
      # --- Toolchain ---
      gcc gnumake gfortran binutils pkg-config cmake
      # --- Libraries & Headers ---
      openssl openssl.dev curl curl.dev libxml2 libxml2.dev zlib zlib.dev
      freetype freetype.dev fontconfig fontconfig.dev harfbuzz harfbuzz.dev
      fribidi fribidi.dev icu icu.dev libpng libpng.dev libjpeg libjpeg.dev
      libtiff libtiff.dev libwebp cairo cairo.dev pango pango.dev rPackages.V8
      udunits
    ]);
    runScript = "rstudio";
  };
in
{
  home.packages = with pkgs; [
    # Utils
    gearlever usbimager wl-clipboard selfprivacy-app btop-rocm
    # Chat
    vesktop fluffychat signal-desktop flare
    # Email
    thunderbird protonmail-bridge-gui
    # Internet
    mullvad-browser librewolf nextcloud-client
    # Media
    mpv krita
    # Music
    picard chromaprint lrcget mixxx ardour tidal-hifi feishin cavasik
    # AI
    gemini-cli
    # Math
    rstudio-fhs
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
  programs.zen-browser.suppressXdgMigrationWarning = true;

  # Math Junk Desktop Entries
  xdg.desktopEntries = {
    rstudio-fhs = {
      name = "RStudio (FHS)";
      genericName = "Integrated Development Environment";
      comment = "RStudio with FHS environment for compilation";
      exec = "rstudio-fhs %F";
      icon = "${pkgs.rstudio}/share/icons/hicolor/256x256/apps/rstudio.png";
      terminal = false;
      categories = [ "Development" "Science" "Education" ];
      mimeType = [ "text/x-r-source" "application/x-r-data" ];
    };
  };

  # Flatpak
  services.flatpak.enable = true;
  services.flatpak.packages = [
    "org.gnome.World.PikaBackup"
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
      Context.sockets = [ "wayland" "!x11" "!fallback-x11" ];
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
