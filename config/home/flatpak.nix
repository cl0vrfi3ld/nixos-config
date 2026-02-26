# user-level flatpak config
{ config, pkgs, ... }:

{
  services.flatpak.enable = true;

  # flatpak packages to be installed/managed via nix
  services.flatpak.packages = [
    "org.gnome.World.PikaBackup"
    "com.github.zocker_160.SyncThingy"
    "com.toolstack.Folio" # markdown editor
    "re.sonny.Eloquent" # proofreading
    "com.moonlight_stream.Moonlight"
    "com.unicornsonlsd.finamp"
    "org.vinegarhq.Sober"
  ];

  # package overrides
  services.flatpak.overrides = {
    global = {
      # Force Wayland by default
      Context.sockets = [
        "wayland"
        "!x11"
        "!fallback-x11" # remove the `!` if we want to allow a an x11 fallback
      ];
      # allow access to the nix store
      Context.filesystems = [ "/nix/store:ro" ];
    };

    # pika backup overrides
    "org.gnome.World.PikaBackup" = {
      Environment = {
        SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
      };
      Context = {
        sockets = [ "ssh-agent" ];
        filesystems = [
          "/home/coucoucl0vr/.bitwarden-ssh-agent.sock"
        ];
      };
    };
  };
}
