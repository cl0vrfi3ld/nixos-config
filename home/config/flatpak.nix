# user-level flatpak config
{ config, pkgs, ... }:

{
    # flatpak packages to be installed/managed via nix
    services.flatpak.packages = [
        "org.gnome.World.PikaBackup"
        "com.github.zocker_160.SyncThingy"
        "com.toolstack.Folio" # markdown editor
        "re.sonny.Eloquent" # proofreading
        "com.moonlight_stream.Moonlight"
        "com.unicornsonlsd.finamp"
    ];

    # package overrides
    services.flatpak.overrides = {
        global = {
            # Force Wayland by default
            #  Context.sockets = ["wayland" "!x11" "!fallback-x11"];
        };

        # bitwarden overrides
        # "com.bitwarden.desktop" = {
        #     Environment = {
        #         BITWARDEN_SSH_AUTH_SOCK = "/home/coucoucl0vr/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock";
        #     };
        #     Context = {
        #         sockets = ["ssh-agent"];
        #     };
        # };

        # pika backup overrides
        "org.gnome.World.PikaBackup" = {
            Environment = {
                SSH_AUTH_SOCK = "/home/coucoucl0vr/.bitwarden-ssh-agent.sock";
            };
            Context = {
                sockets = ["ssh-agent"];
                filesystems = [
                    "/home/coucoucl0vr/.bitwarden-ssh-agent.sock"
                ];
            };
        };
    };
}
