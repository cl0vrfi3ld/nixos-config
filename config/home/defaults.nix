# XDG app defaults configuration
{ ... }:
{
  # set default apps
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    # make dolphin the default file manager
    "inode/directory" = "org.kde.dolphin.desktop";
    # make okular the default document viewer
    "application/pdf" = "org.kde.okular.desktop";

    # make kate the default text/code editor
    "text/plain" = "org.kde.kate.desktop";
    "text/markdown" = "org.kde.kate.desktop";
  };
}
