# XDG app defaults configuration
{ ... }:
{
  # set default apps
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    # Directory
    "inode/directory" = "org.kde.dolphin.desktop";

    # Web Browser
    "text/html" = "zen-twilight.desktop";
    "x-scheme-handler/http" = "zen-twilight.desktop";
    "x-scheme-handler/https" = "zen-twilight.desktop";
    "x-scheme-handler/about" = "zen-twilight.desktop";
    "x-scheme-handler/unknown" = "zen-twilight.desktop";

    # Email
    "x-scheme-handler/mailto" = "thunderbird.desktop";
    "message/rfc822" = "thunderbird.desktop";

    # Image Viewer
    "image/jpeg" = "org.kde.gwenview.desktop";
    "image/png" = "org.kde.gwenview.desktop";
    "image/gif" = "org.kde.gwenview.desktop";
    "image/webp" = "org.kde.gwenview.desktop";
    "image/svg+xml" = "org.kde.gwenview.desktop";

    # Video Player
    "video/mp4" = "vlc.desktop";
    "video/x-matroska" = "vlc.desktop";
    "video/webm" = "vlc.desktop";
    "video/quicktime" = "vlc.desktop";
    "video/x-msvideo" = "vlc.desktop";

    # Audio Player
    "audio/mpeg" = "org.kde.elisa.desktop";
    "audio/x-flac" = "org.kde.elisa.desktop";
    "audio/wav" = "org.kde.elisa.desktop";
    "audio/ogg" = "org.kde.elisa.desktop";

    # Office Suite (OnlyOffice & PDF)
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "onlyoffice-desktopeditors.desktop";
    "application/msword" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-excel" = "onlyoffice-desktopeditors.desktop";
    "application/vnd.ms-powerpoint" = "onlyoffice-desktopeditors.desktop";
    "application/pdf" = "org.kde.okular.desktop";

    # Archive Manager
    "application/zip" = "org.kde.ark.desktop";
    "application/x-tar" = "org.kde.ark.desktop";
    "application/x-compressed-tar" = "org.kde.ark.desktop";
    "application/x-gzip" = "org.kde.ark.desktop";
    "application/x-bzip2" = "org.kde.ark.desktop";
    "application/x-xz" = "org.kde.ark.desktop";

    # Development (Code vs Config/Text)
    "text/plain" = "org.kde.kate.desktop";
    "text/markdown" = "org.kde.kate.desktop";
    "text/x-nix" = "codium.desktop";
    "text/x-rust" = "codium.desktop";
    "text/x-python" = "codium.desktop";
    "application/json" = "codium.desktop";

    # Terminal
    "x-scheme-handler/terminal" = "com.mitchellh.ghostty.desktop";
    "x-scheme-handler/ssh" = "com.mitchellh.ghostty.desktop";
    "x-scheme-handler/telnet" = "com.mitchellh.ghostty.desktop";
  };
}
