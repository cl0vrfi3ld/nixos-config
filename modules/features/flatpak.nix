{
  self,
  inputs,
  lib,
  ...
}:
{
  flake.nixosModules.flatpak =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      config = {
        # Flatpak
        services.flatpak.enable = true;
        services.flatpak.packages = [
          "dev.deedles.Trayscale"
        ];
        services.flatpak.overrides = {
          global = {
            Context.filesystems = [ "/nix/store:ro" ];
          };
        };

        # HM module needed by the home-level flatpak options
        home-manager.sharedModules = [ inputs.nix-flatpak.homeManagerModules.nix-flatpak ];

        # Home-Manager configuration per user
        home-manager.users = self.lib.applyDesktopHome config (username: {
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
        });
      };
    };
}
